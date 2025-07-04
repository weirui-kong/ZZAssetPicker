//
//  ZZAPAssetSelectionBaseViewController.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/14/25.
//

import UIKit
import Photos

// MARK: - Layout Mode Enum

/// Layout strategy for asset grid
@objc public enum ZZAPAssetLayoutMode: Int {
    case fixed         // Fixed number of items per row
    case adaptiveFill  // Adaptive fill based on screen width (default)
}

// MARK: - Delegate Protocol

/// Asset selection delegate for handling tap actions
@objc public protocol ZZAPAssetSelectionDelegate: AnyObject {
    func assetSelectionViewController(
        _ controller: ZZAPAssetSelectionBaseViewController,
        didTapAsset asset: PHAsset,
        thumbnail: UIImage?,
        sourceFrame: CGRect
    )
}

// MARK: - Main Asset Picker ViewController

@objcMembers
public class ZZAPAssetSelectionBaseViewController: UIViewController {
    
    // MARK: - Public Configurable Properties
    
    public var mediaSubtypeBadgeOption: ZZAPMediaSubtypeBadgeOption = .none

    public var store: ZZAPAssetStore? {
        didSet {
            self.collectionView?.reloadData()
            if store == nil {
                loadingIndicator.isHidden = false
                loadingIndicator.startAnimating()
            } else {
                loadingIndicator.isHidden = true
                loadingIndicator.stopAnimating()
            }
        }
    }
    
    /// Determines layout strategy
    public var layoutMode: ZZAPAssetLayoutMode = .adaptiveFill
    
    /// Used in `.fixed` mode: number of items per row
    public var fixedItemsPerRow: Int = 4
    
    /// Used in `.adaptiveFill` mode: target item width
    public var desiredItemWidth: CGFloat = 90
    
    /// Spacing between rows and items
    public var itemSpacing: CGFloat = 2
    
    /// External delegate for asset interaction
    public weak var delegate: ZZAPAssetSelectionDelegate?
    
    public var selectionController: ZZAPSelectable? {
        willSet {
            self.selectionController?.removeSelectableDelegate?(self)
        }
        didSet {
            self.selectionController?.addSelectableDelegate?(self)
        }
    }
    
    public var thumbnailImageQuality: ZZAPThumbnailImageQuality = .device

    // MARK: - Internal State
    
    private var collectionView: UICollectionView!
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Loading Blur

    private var validationLoadingTask: DispatchWorkItem?
    private var loadingOverlayView: UIView?

    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCollectionView()
        setupLoadingIndicator()
        self.collectionView.reloadData()
    }
    
    // MARK: - Setup Methods
    
    /// Setup and configure loading view layout and appearance
    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
        loadingIndicator.snp.makeConstraints { make in
            make.centerX.equalTo(self.view.snp.centerX)
            make.centerY.equalTo(self.view.snp.centerY)
        }
    }
    
    /// Setup and configure collection view layout and appearance
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = itemSpacing
        layout.minimumInteritemSpacing = itemSpacing
        layout.itemSize = calculateItemSize()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.contentSize = view.bounds.size
        collectionView.clipsToBounds = false
        
        // Register cell types
        collectionView.register(ZZAPImageCell.self, forCellWithReuseIdentifier: ZZAPImageCell.reuseIdentifier)
        collectionView.register(ZZAPVideoCell.self, forCellWithReuseIdentifier: ZZAPVideoCell.reuseIdentifier)
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalTo(self.view)
        }
        
    }
    
    /// Computes the item size based on current layout mode
    /// - Returns: Calculated CGSize for collection view items
    private func calculateItemSize() -> CGSize {
        let availableWidth = UIScreen.main.bounds.width
        
        switch layoutMode {
        case .fixed:
            let count = max(fixedItemsPerRow, 1)
            let totalSpacingBetweenItems = itemSpacing * CGFloat(count - 1)
            let itemWidth = (availableWidth - totalSpacingBetweenItems) / CGFloat(count)
            return CGSize(width: itemWidth, height: itemWidth)
            
        case .adaptiveFill:
            let count = max(Int((availableWidth + itemSpacing) / (desiredItemWidth + itemSpacing)), 1)
            let itemWidth = (availableWidth - itemSpacing * CGFloat(count - 1)) / CGFloat(count)
            return CGSize(width: itemWidth, height: itemWidth)
            
        @unknown default:
            return CGSize(width: 100, height: 100)
        }
    }
    
    @MainActor
    private func handleSelectionChanged(_ selectedAssets: [Int : ZZAPAsset]) {
        collectionView.visibleCells.forEach { cell in
            guard let cell = cell as? ZZAPAssetRepresentable else {
                print("Warning: Cell is not of type ZZAPAssetRepresentable")
                return
            }
            if let index = selectedAssets.firstIndex(where: { $0.value.id == cell.asset?.id }) {
                cell.selectedIndex = selectedAssets[index].key
            } else {
                cell.selectedIndex = 0
            }
        }
    }
    
    // MARK: - Update UI
    @MainActor
    public func updateContentInset(inset: UIEdgeInsets) {
        collectionView.contentInset = inset
        loadingIndicator.snp.updateConstraints { make in
            make.centerX.equalTo(self.view.snp.centerX).offset(-(inset.right - inset.left)/2)
            make.centerY.equalTo(self.view.snp.centerY).offset(-(inset.bottom - inset.top)/2)
        }
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

}

// MARK: - UICollectionViewDataSource

extension ZZAPAssetSelectionBaseViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return store?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let asset = store?.asset(at: indexPath.item) else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: ZZAPImageCell.reuseIdentifier, for: indexPath)
        }
        
        let identifier: String
        switch asset.mediaType {
        case .video:
            identifier = ZZAPVideoCell.reuseIdentifier
        case .image, .unknown, .audio:
            fallthrough
        default:
            identifier = ZZAPImageCell.reuseIdentifier
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        
        if let cellBase = cell as? ZZAPAssetCellBase {
            cellBase.delegate = self
            cellBase.mediaSubtypeBadgeOption = self.mediaSubtypeBadgeOption
        }
        
        if let assetRepresentable = cell as? ZZAPAssetRepresentable {
            assetRepresentable.thumbnailImageQuality = thumbnailImageQuality
            assetRepresentable.clearWhenPreparingForReuse = asset.sourceType != .photoLibrary
            assetRepresentable.configure(with: asset)
            assetRepresentable.selectionMode = self.selectionController?.selectionMode ?? .none
            assetRepresentable.selectedIndex = self.selectionController?.selectedAssets
                .compactMap { $1.id == asset.id ? $0 : nil }
                .first ?? 0
        }
        
        return cell
    }
}

// MARK: - ZZAPSelectableDelegate

extension ZZAPAssetSelectionBaseViewController: ZZAPSelectableDelegate {
    public func selectable(_ selectable: any ZZAPSelectable, from sender: AnyObject?, didChangeSelection selectedAssets: [Int : any ZZAPAsset]) {
        
        handleSelectionChanged(selectedAssets)
        if let sender = sender, sender === self {
            print("Selection updated, triggered by me.")
        } else {
            //print("Selection updated, not triggered by me.")
        }
    }
    
    public func selectable(_ selectable: any ZZAPSelectable, from sender: AnyObject?, didStartSelectionValidatoin asset: any ZZAPAsset) {
        guard let sender = sender, sender === self else { return }

        let task = DispatchWorkItem { [weak self] in
            self?.showValidationLoadingOverlay()
        }
        self.validationLoadingTask = task

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: task)
    }

    public func selectable(_ selectable: any ZZAPSelectable, from sender: AnyObject?, didEndSelectionValidatoin asset: any ZZAPAsset, mayFail failure: ZZAPAssetValidationFailure?) {
        guard let sender = sender, sender === self else { return }

        self.validationLoadingTask?.cancel()
        self.validationLoadingTask = nil

        self.hideValidationLoadingOverlay()

        if let failure = failure {
            print(failure.message + ", triggered by me.")
            print(failure.extra)
        }
    }

}

// MARK: - Loading Blur

extension ZZAPAssetSelectionBaseViewController {
    private func showValidationLoadingOverlay() {
        guard loadingOverlayView == nil else { return }

        let overlay = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        overlay.frame = self.view.bounds
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlay.alpha = 0.0
        
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.center = overlay.contentView.center
        indicator.startAnimating()
        overlay.contentView.addSubview(indicator)
        
        self.view.addSubview(overlay)
        self.loadingOverlayView = overlay

        UIView.animate(withDuration: 0.25) {
            overlay.alpha = 1.0
        }
    }

    private func hideValidationLoadingOverlay() {
        guard let overlay = self.loadingOverlayView else { return }

        UIView.animate(withDuration: 0.25, animations: {
            overlay.alpha = 0.0
        }, completion: { _ in
            overlay.removeFromSuperview()
        })

        self.loadingOverlayView = nil
    }

}

// MARK: - ZZAPAssetSelectionDelegate

extension ZZAPAssetSelectionBaseViewController: ZZAPAssetCellBaseDelegate {
    public func assetCell(_ cell: ZZAPAssetCellBase, didTapBadgeFor asset: (any ZZAPAsset)?) {
        guard let asset = asset else { return }
        let index = self.selectionController?.index?(self, for: asset) ?? NSNotFound
        if index == NSNotFound {
            self.selectionController?.addAsset?(self, asset)
        } else {
            self.selectionController?.removeAsset?(self, at: index)
        }
        
    }
}

// MARK: - UICollectionViewDelegate

extension ZZAPAssetSelectionBaseViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ZZAPAssetRepresentable,
              let cellView = cell as? UIView,
              let window = view.window else { return }
        
        let fromFrame = cellView.convert(cellView.bounds, to: window)
        let transitionContext = ZZAPTransitionContext(fromImage: cell.thumbnailImage, fromFrame: fromFrame)
        
        guard let asset = self.store?.asset(at: indexPath.item) else { return }
        
        preview(selectionContext: nil, transitionContext: transitionContext)
    }
}

// MARK: - Thumbnail Fetching

private extension ZZAPAssetSelectionBaseViewController {
    /// Quickly retrieves a small thumbnail for transition animation
    /// - Parameters:
    ///   - asset: The PHAsset to fetch thumbnail for
    ///   - completion: Completion handler with optional UIImage result
    func getThumbnail(for asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.deliveryMode = .fastFormat
        option.resizeMode = .fast
        option.isSynchronous = false
        
        let targetSize = CGSize(width: 200, height: 200)
        manager.requestImage(for: asset,
                             targetSize: targetSize,
                             contentMode: .aspectFill,
                             options: option) { image, _ in
            completion(image)
        }
    }
    
    // TODO: Dev code... will be removed later
    @MainActor
    @objc public func preview(selectionContext: ZZAPSelectionContext?, transitionContext: ZZAPTransitionContext?) {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
              let image = transitionContext?.fromImage else {
            return
        }

        let startFrame = transitionContext?.fromFrame ?? .zero

        let animatingImageView = UIImageView(image: image)
        animatingImageView.contentMode = .scaleAspectFill
        animatingImageView.clipsToBounds = true
        animatingImageView.frame = startFrame

        window.addSubview(animatingImageView)

        let backgroundView = UIView(frame: window.bounds)
        backgroundView.backgroundColor = .black
        backgroundView.alpha = 0
        window.insertSubview(backgroundView, belowSubview: animatingImageView)

        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.8,
            options: [.curveEaseInOut],
            animations: {
                animatingImageView.frame = window.bounds
                backgroundView.alpha = 1
            },
            completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    animatingImageView.removeFromSuperview()
                    backgroundView.removeFromSuperview()
                }
            }
        )
    }
}
