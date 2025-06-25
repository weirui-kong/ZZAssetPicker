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
    private let scrollView = UIScrollView()
    private var pageViewControllers: [ZZAPAssetSelectionBaseViewController]

    public private(set) var config: ZZAssetPickerConfiguration
    
    // MARK: - Lifecycle
    
    init(config: ZZAssetPickerConfiguration, tabTypes: [ZZAPTabType], selectionController: ZZAPSelectable, pageViewControllers: [ZZAPAssetSelectionBaseViewController]) {
        self.config = config
        self.tabTypes = tabTypes
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
        viewController.layoutMode = .adaptiveFill
        viewController.desiredItemWidth = 90
        viewController.itemSpacing = 2
        viewController.selectionController = self.selectionController
        viewController.mediaSubtypeBadgeOption = self.config.userInterfaceConfig.mediaSubtypeBadgeOption
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        switch tab {
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
        viewController.loadViewIfNeeded()
        viewController.updateContentInset(inset: UIEdgeInsets(top: 0, left: 0, bottom: indicatorBar.intrinsicContentSize.height, right: 0))

        DispatchQueue.global().async {
            let store = ZZAPAssetStore(fetchResult: PHAsset.fetchAssets(with: options))
            DispatchQueue.main.async {
                viewController.store = store
            }
        }

        return viewController
    }
}

// MARK: - ZZAPSelectableDelegate

extension ZZAPAssetSelectionPolyViewController: ZZAPSelectableDelegate {
    public func selectable(_ selectable: any ZZAPSelectable, from sender: AnyObject?, didChangeSelection selectedAssets: [Int : any ZZAPAsset]) {
        for subPage in pageViewControllers {
            subPage.updateContentInset(inset: UIEdgeInsets(top: 0, left: 0, bottom: indicatorBar.intrinsicContentSize.height, right: 0))
        }
    }
}
