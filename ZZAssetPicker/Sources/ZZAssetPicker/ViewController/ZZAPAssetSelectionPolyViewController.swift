//
//  ZZAPAssetSelectionPolyViewController.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/17/25.
//

import UIKit
import Photos
import SnapKit

@objcMembers
public class ZZAPAssetSelectionPolyViewController: UIViewController {

    // MARK: - Properties

    private var selectionController: ZZAPSelectable

    private var tabTypes: [ZZAPTabType]
    private var collections: [PHAssetCollection?] = []
    private let scrollView = UIScrollView()
    private var pageViewControllers: [ZZAPAssetSelectionBaseViewController]

    public private(set) var config: ZZAssetPickerConfiguration
    
    // MARK: - Lifecycle
    
    init(config: ZZAssetPickerConfiguration, tabTypes: [ZZAPTabType], collections: [PHAssetCollection?] = [], selectionController: ZZAPSelectable, pageViewControllers: [ZZAPAssetSelectionBaseViewController]) {
        self.config = config
        self.tabTypes = tabTypes
        self.collections = collections
        self.selectionController = selectionController
        self.pageViewControllers = pageViewControllers
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        selectionController.addSelectableDelegate?(self)
        setupScrollView()
        setupPages()
        setupIndicator()

        // If collections is empty, fetch system albums
        if collections.isEmpty {
            fetchQuickDefaultCollection()
            fetchSystemCollections()
        }
    }

    // MARK: - Setup Scroll View

    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.isScrollEnabled = true

        scrollView.snp.makeConstraints { make in
            make.top.left.right.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.snp.bottom)
        }
    }

    // MARK: - Setup Pages

    private func setupPages() {
        var previousPage: UIView?
        for tabType in tabTypes {
            let viewController = createPageController(for: tabType)
            addChild(viewController)
            scrollView.addSubview(viewController.view)
            viewController.didMove(toParent: self)
            pageViewControllers.append(viewController)

            viewController.view.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.width.equalTo(scrollView.snp.width)
                make.height.equalTo(scrollView.snp.height)
                if let previous = previousPage {
                    make.left.equalTo(previous.snp.right)
                } else {
                    make.left.equalToSuperview()
                }
            }

            previousPage = viewController.view
        }
        previousPage?.snp.makeConstraints { make in
            make.right.equalToSuperview()
        }
    }

    // MARK: - DEV ONLY
    private let indicatorBar = ZZAPSelectionIndicatorBar()
    private func setupIndicator() {
        indicatorBar.selectionController = self.selectionController
        view.addSubview(indicatorBar)
        
        indicatorBar.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(self.view)
        }
    }


    // MARK: - Factory

    private func createPageController(for tab: ZZAPTabType) -> ZZAPAssetSelectionBaseViewController {
        let viewController = ZZAPAssetSelectionBaseViewController()
        viewController.thumbnailImageQuality = self.config.resourceConfig.thumbnailQuality
        viewController.layoutMode = .adaptiveFill
        viewController.desiredItemWidth = 90
        viewController.itemSpacing = 2
        viewController.selectionController = self.selectionController
        viewController.mediaSubtypeBadgeOption = self.config.userInterfaceConfig.mediaSubtypeBadgeOption
        viewController.loadViewIfNeeded()
        viewController.updateContentInset(inset: UIEdgeInsets(top: 0, left: 0, bottom: indicatorBar.intrinsicContentSize.height, right: 0))
        // Do not set store here
        return viewController
    }

    // MARK: - Fetch System Collections
    private func fetchQuickDefaultCollection() {
        // assetCollectionType = .smartAlbum (2), subtype = 209
        // Which is almost equal to `all photos`
        let quickAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: PHAssetCollectionSubtype(rawValue: 209) ?? .any, options: nil)
        var defaultCollection: PHAssetCollection? = nil
        quickAlbums.enumerateObjects { (collection, _, stop) in
            defaultCollection = collection
            stop.pointee = true
        }

        if let defaultCollection = defaultCollection {
            self.collections = [defaultCollection]
            self.updateCollections(newCollections: [defaultCollection])
        }
    }

    private func fetchSystemCollections() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }

            var collections: [PHAssetCollection] = []

            let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
            smartAlbums.enumerateObjects { (collection, _, _) in
                collections.append(collection)
            }

            let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
            userAlbums.enumerateObjects { (collection, _, _) in
                collections.append(collection)
            }
            
            DispatchQueue.main.async {
                self.collections = collections
            }
        }
    }


    // MARK: - Update Collections and Set Data Source
    public func updateCollections(newCollections: [PHAssetCollection?]) {
        self.collections = newCollections
        for (index, tabType) in tabTypes.enumerated() {
            guard let vc = pageViewControllers[safe: index] else { continue }
            let collection = newCollections.indices.contains(index) ? newCollections[index] : nil
            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            switch tabType {
            case .videos:
                options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
            case .photos:
                options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
            case .livePhotos:
                options.predicate = NSPredicate(format: "mediaType == %d AND (mediaSubtypes & %d) != 0",
                                                PHAssetMediaType.image.rawValue,
                                                PHAssetMediaSubtype.photoLive.rawValue)
            case .all:
                break
            }
            DispatchQueue.global().async {
                let fetchResult: PHFetchResult<PHAsset>
                if let collection = collection {
                    fetchResult = PHAsset.fetchAssets(in: collection, options: options)
                } else {
                    fetchResult = PHAsset.fetchAssets(with: options)
                }
                let store = ZZAPAssetStore(fetchResult: fetchResult)
                DispatchQueue.main.async {
                    vc.store = store
                }
            }
        }
    }
}

// MARK: - ZZAPSelectableDelegate

extension ZZAPAssetSelectionPolyViewController: ZZAPSelectableDelegate {
    public func selectable(_ selectable: any ZZAPSelectable, from sender: AnyObject?, didChangeSelection selectedAssets: [Int : any ZZAPAsset]) {
        for subPage in pageViewControllers {
            subPage.updateContentInset(inset: UIEdgeInsets(top: 0, left: 0, bottom: indicatorBar.intrinsicContentSize.height, right: 0))
        }
    }
    
    public func selectable(_ selectable: any ZZAPSelectable, from sender: AnyObject?, didStartSelectionValidatoin asset: any ZZAPAsset) {
        self.view.isUserInteractionEnabled = false
    }
    
    public func selectable(_ selectable: any ZZAPSelectable, from sender: AnyObject?, didEndSelectionValidatoin asset: any ZZAPAsset, mayFail failure: ZZAPAssetValidationFailure?) {
        self.view.isUserInteractionEnabled = true
    }
}

// MARK: - Array Safe Subscript
fileprivate extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
