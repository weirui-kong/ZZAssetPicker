//
//  ZZAPAssetSelectionViewController.swift
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
        _ controller: ZZAPAssetSelectionViewController,
        didTapAsset asset: PHAsset,
        thumbnail: UIImage?,
        sourceFrame: CGRect
    )
}

// MARK: - Main Asset Picker ViewController

@objcMembers
public class ZZAPAssetSelectionViewController: UIViewController {

    // MARK: - Public Configurable Properties

    /// Determines layout strategy
    public var layoutMode: ZZAPAssetLayoutMode = .fixed

    /// Used in `.fixed` mode: number of items per row
    public var fixedItemsPerRow: Int = 4

    /// Used in `.adaptiveFill` mode: target item width
    public var desiredItemWidth: CGFloat = 100

    /// Spacing between rows and items
    public var itemSpacing: CGFloat = 2

    /// External delegate for asset interaction
    public weak var delegate: ZZAPAssetSelectionDelegate?

    public var selectionController: ZZAPSelectable = ZZAPSelectionControllerCommon()

    // MARK: - Internal State

    private var collectionView: UICollectionView!
    private var store: ZZAPAssetStore?

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCollectionView()
        requestPhotoAccessAndFetchAssets()
    }

    // MARK: - Setup Methods

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

        // Register cell types
        collectionView.register(ZZAPImageCell.self, forCellWithReuseIdentifier: ZZAPImageCell.reuseIdentifier)
        collectionView.register(ZZAPVideoCell.self, forCellWithReuseIdentifier: ZZAPVideoCell.reuseIdentifier)

        view.addSubview(collectionView)
    }

    /// Computes the item size based on current layout mode
    /// - Returns: Calculated CGSize for collection view items
    private func calculateItemSize() -> CGSize {
        let totalSpacing = itemSpacing * 2
        let availableWidth = UIScreen.main.bounds.width - totalSpacing

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

    // MARK: - Photo Access and Fetching

    /// Request permission to access photo library and fetch assets upon success
    private func requestPhotoAccessAndFetchAssets() {
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                guard status == .authorized || status == .limited else { return }

                DispatchQueue.main.async {
                    self.fetchAssets()
                }
            }
        } else {
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized else { return }

                DispatchQueue.main.async {
                    self.fetchAssets()
                }
            }
        }
    }

    /// Fetch assets from photo library sorted by creation date descending
    private func fetchAssets() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        self.store = ZZAPAssetStore(fetchResult: PHAsset.fetchAssets(with: options))
        self.collectionView.reloadData()
        
        var sampleAssets: [ZZAPAsset] = [ZZAPAsset]()
        for _ in 0..<200 {
            let sampleAsset = ZZAPRemoteAsset(remoteURL: URL(string: "https://avatar.iran.liara.run/public")!)
            sampleAsset.cacheToMemory = true
            sampleAssets.append(sampleAsset)
        }
        // self.store = ZZAPAssetStore(customAssets: sampleAssets)
        
    }
}

// MARK: - UICollectionViewDataSource

extension ZZAPAssetSelectionViewController: UICollectionViewDataSource {
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

        if let assetCell = cell as? ZZAPAssetRepresentable {
            assetCell.clearWhenPreparingForReuse = asset.sourceType != .photoLibrary
            assetCell.configure(with: asset)
            assetCell.selectionMode = self.selectionController.selectionMode ?? .none
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ZZAPAssetSelectionViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ZZAPAssetRepresentable,
              let cellView = cell as? UIView,
              let window = view.window else { return }

        let fromFrame = cellView.convert(cellView.bounds, to: window)
        let transitionContext = ZZAPTransitionContext(fromImage: cell.thumbnailImage, fromFrame: fromFrame)

        guard let asset = self.store?.asset(at: indexPath.item) else { return }
        
        selectionController.handleTap?(
            on: asset,
            at: indexPath,
            transitionContext: transitionContext
        )
    }
}

// MARK: - Thumbnail Fetching

private extension ZZAPAssetSelectionViewController {
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
}
