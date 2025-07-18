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
public class ZZAPAssetSelectionPolyViewController: ZZAPBaseViewController {

    // MARK: - Properties

    private var selectionController: ZZAPSelectable

    private var collectionPresenter: ZZAPCollectionPresenter
    private let collectionPresenterView = ZZAPCollectionPresenterView()

    private var tabTypes: [ZZAPTabType]
    private let tabView = ZZAPTabView()
    private let scrollView = UIScrollView()
    private var coordinator: ZZAPScrollCoordinator?

    private var pageViewControllers: [ZZAPAssetSelectionBaseViewController]

    public private(set) var config: ZZAssetPickerConfiguration
    
    private var sortOption = ZZAPSortOption.creationDateDescending
    private var menuButton: UIButton?

    // MARK: - Lifecycle
    
    init(config: ZZAssetPickerConfiguration, tabTypes: [ZZAPTabType], collectionPresenter: ZZAPCollectionPresenter, selectionController: ZZAPSelectable, pageViewControllers: [ZZAPAssetSelectionBaseViewController]) {
        self.config = config
        self.tabTypes = tabTypes
        self.collectionPresenter = collectionPresenter
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
        setupCollectionPresenterView()
        setupTabView()
        setupScrollView()
        setupPages()
        setupIndicator()
        setupCoordinator()
        selectionController.addSelectableDelegate?(self)
        collectionPresenter.addCollectionDelegate?(self)
        collectionPresenter.reloadCollections()
    }
    
    private var didPlaceTabViewIndicator = false
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !didPlaceTabViewIndicator {
            tabView.layoutIfNeeded()
            tabView.setSelectedIndex(tabView.selectedIndex, animated: false)
            didPlaceTabViewIndicator.toggle()
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        coordinator?.selectTab(at: coordinator?.tabView?.selectedIndex ?? 0, animated: false)
    }
    public override func viewDidAppear(_ animated: Bool) {
        //coordinator?.selectTab(at: coordinator?.tabView?.selectedIndex ?? 0, animated: false)
    }

    // MARK: - Setup Tab View
    private func setupCollectionPresenterView() {
        view.addSubview(collectionPresenterView)
        collectionPresenterView.presenter = collectionPresenter
        collectionPresenterView.onSelect = { [weak self] collection in
            
        }
        collectionPresenterView.snp.makeConstraints { make in
            make.top.equalTo(contentTopConstraintTarget)
            make.left.right.equalToSuperview()
        }
    }

    private func setupTabView() {
        view.addSubview(tabView)
        tabView.setupTabs(tabs: self.tabTypes)
        tabView.snp.makeConstraints { make in
            make.top.equalTo(collectionPresenterView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
    }
    
    // MARK: - Setup Scroll View
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.isScrollEnabled = true

        if view.subviews.contains(tabView) {
            scrollView.snp.makeConstraints { make in
                make.top.equalTo(tabView.snp.bottom)
                make.left.right.bottom.equalTo(view)
            }
        } else {
            scrollView.snp.makeConstraints { make in
                make.top.equalTo(contentTopConstraintTarget)
                make.left.right.bottom.equalTo(view)
            }
        }
    }
    
    // MARK: - Setup Coordinator
    private func setupCoordinator() {
        coordinator = ZZAPScrollCoordinator(tabView: tabView, scrollView: scrollView)
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

    // MARK: - Update Collection and Set Data Source
    public func updateCollection() {
        for (index, tabType) in tabTypes.enumerated() {
            guard let vc = pageViewControllers[safe: index] else { continue }
            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: sortOption.photoKitSortKey, ascending: sortOption.isAscending)]
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
            let collection = collectionPresenter.currentCollection
            DispatchQueue.global().async {
                let fetchResult: PHFetchResult<PHAsset>
                if let collection = collection {
                    fetchResult = PHAsset.fetchAssets(in: collection, options: options)
                } else {
                    fetchResult = PHAsset.fetchAssets(with: options)
                }
                let store = ZZAPAssetStore(fetchResult: fetchResult)
                DispatchQueue.main.async {
                    vc.collectionView.zzap_restoreFromConvergence()
                    vc.store = store
                }
            }
        }
    }
}

extension ZZAPAssetSelectionPolyViewController {


    public override func requiresNavigationBarView() -> Bool {
        true
    }

    public override func navigationBarTitle() -> String? {
        "ZZAsserPicker"
    }

    public override func navigationBarLeftButtons() -> [UIButton] {
        let closeButton = UIButton(type: .system)
        let image = UIImage(zzap_named: "xmark")
        closeButton.setImage(image, for: .normal)
        closeButton.contentMode = .scaleAspectFit
        closeButton.tintColor = .black
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        closeButton.snp.makeConstraints { make in
            make.width.height.equalTo(18)
        }
        return [closeButton]
    }

    public override func navigationBarRightButtons() -> [UIButton] {
        let button = UIButton(type: .system)
        let image = UIImage(zzap_named: "line.horizontal.3.decrease")
        button.setImage(image, for: .normal)
        button.contentMode = .scaleAspectFit
        button.tintColor = .black
        button.snp.makeConstraints { make in
            make.width.height.equalTo(18)
        }

        menuButton = button

        if #available(iOS 14.0, *) {
            button.menu = makeSortMenu()
            button.showsMenuAsPrimaryAction = true
        } else {
            button.addTarget(self, action: #selector(menuButtonTappedLegacy(_:)), for: .touchUpInside)
        }
        return [button]
    }

    @available(iOS 14.0, *)
    private func makeSortMenu() -> UIMenu {
        let creationDesc = UIAction(title: ZZAPSortOption.creationDateDescending.localizedString, state: sortOption == .creationDateDescending ? .on : .off) { [weak self] _ in
            self?.updateSortOption(.creationDateDescending)
        }
        
        let creationAsc = UIAction(title: ZZAPSortOption.creationDateAscending.localizedString, state: sortOption == .creationDateAscending ? .on : .off) { [weak self] _ in
            self?.updateSortOption(.creationDateAscending)
        }
        return UIMenu(title: ZZAPLocalized("zzap_sort_menu_section_title_sort_option"), children: [creationDesc, creationAsc])
    }

    @objc private func menuButtonTappedLegacy(_ sender: UIButton) {
        showLegacySortMenu()
    }

    private func showLegacySortMenu() {
        let alert = UIAlertController(title: ZZAPLocalized("zzap_sort_menu_section_title_sort_option"), message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: ZZAPSortOption.creationDateDescending.localizedString, style: .default, handler: { [weak self] _ in
            self?.updateSortOption(.creationDateDescending)
        }))
        alert.addAction(UIAlertAction(title: ZZAPSortOption.creationDateAscending.localizedString, style: .default, handler: { [weak self] _ in
            self?.updateSortOption(.creationDateAscending)
        }))
        
        alert.addAction(UIAlertAction(title: ZZAPLocalized("zzap_sort_menu_section_title_cancel"), style: .cancel))
        present(alert, animated: true)
    }

    private func updateSortOption(_ newOption: ZZAPSortOption) {
        guard newOption != sortOption else { return }
        sortOption = newOption
        for vc in pageViewControllers {
            vc.collectionView.zzap_convergeToCenter()
        }
        updateCollection()

        if #available(iOS 14.0, *), let btn = menuButton {
            btn.menu = makeSortMenu()
        }
    }

    @objc private func closeButtonTapped() {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
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

// MARK: - ZZAPCollectionPresenterDelegate

extension ZZAPAssetSelectionPolyViewController: ZZAPCollectionPresenterDelegate {

    public func collectionPresenter(_ presenter: ZZAPCollectionPresenter, didUpdateCurrentCollection collection: PHAssetCollection?) {
        updateCollection()
    }
}

// MARK: - Array Safe Subscript
fileprivate extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
