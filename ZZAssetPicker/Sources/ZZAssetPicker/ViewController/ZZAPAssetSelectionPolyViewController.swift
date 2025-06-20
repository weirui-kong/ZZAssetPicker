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

    private var selectionController: ZZAPSelectable = ZZAPSelectionControllerCommon(selectionMode: .multipleCompact, maximumSelection: 5)

    private let tabTypes: [ZZAPTabType] = [.all, .videos, .photos, .livePhotos]
    private let scrollView = UIScrollView()
    private var pageViewControllers: [ZZAPAssetSelectionBaseViewController] = []

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupScrollView()
        setupPages()
        setupIndicator()
        setupValidationRules()
    }

    // MARK: - Setup Validation Rules
    private func setupValidationRules() {
        let durationRule = ZZAPDurationRule(maxDuration: 60)
        let validatior = ZZAPAssetValidatorManager(rules: [durationRule])
        if let selectionController = selectionController as? ZZAPSelectionControllerCommon {
            selectionController.validationManager = validatior
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
            make.edges.equalTo(view.safeAreaLayoutGuide)
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
            make.height.equalTo(180)
        }
        
    }


    // MARK: - Factory

    private func createPageController(for tab: ZZAPTabType) -> ZZAPAssetSelectionBaseViewController {
        let viewController = ZZAPAssetSelectionBaseViewController()
        viewController.layoutMode = .adaptiveFill
        viewController.desiredItemWidth = 90
        viewController.itemSpacing = 2
        viewController.selectionController = self.selectionController
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
        viewController.store = ZZAPAssetStore(fetchResult: PHAsset.fetchAssets(with: options))

        return viewController
    }
}
