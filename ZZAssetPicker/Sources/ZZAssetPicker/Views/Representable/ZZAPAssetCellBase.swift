//
//  ZZAPAssetCellBase.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/14/25.
//

import UIKit
import Photos
import ZZAssetPicker
import Foundation

@objc
public protocol ZZAPAssetCellBaseDelegate: AnyObject {
    @MainActor
    func assetCell(_ cell: ZZAPAssetCellBase, didTapBadgeFor asset: ZZAPAsset?)
}

@objcMembers
public class ZZAPAssetCellBase: UICollectionViewCell, ZZAPAssetRepresentable, ZZAPSelectionBadgeViewDelegate {
    
    // MARK: - Properties
    
    public weak var delegate: ZZAPAssetCellBaseDelegate?
    
    /// Reuse identifier for the cell class
    public class var reuseIdentifier: String {
        return String(describing: self)
    }
    
    /// The PHAsset associated with this cell
    public var asset: ZZAPAsset?
    
    /// The selected index, 0 means unselected
    public var selectedIndex: Int = 0 {
        didSet {
            self.badgeView.index = self.selectedIndex
            self.updateImageSelection(animated: self.shouldAnimateNextUpdate)
        }
    }
    
    /// The selection mode (single, multiple, none)
    public var selectionMode: ZZAPSelectionMode = .single {
        didSet {
            self.badgeView.selectionMode = self.selectionMode
        }
    }
    
    public var mediaSubtypeBadgeOption: ZZAPMediaSubtypeBadgeOption = .none
    
    public var clearWhenPreparingForReuse: Bool = false

    /// Image view displaying the asset thumbnail
    internal let imageView = UIImageView()
    
    /// Controls whether the next update should animate zoom effect
    private var shouldAnimateNextUpdate = false
    
    private let selectedOverlay = UIView()
    internal var badgeView: (ZZAPSelectionBadgeViewProtocol & UIView)!
    
    internal var requestID: PHImageRequestID = 0
    
    
    // MARK: - Initialization
    
    /// Initialize cell with frame, setup subviews
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    /// Not implemented
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Setup
    
    /// Setup subviews and layout constraints
    private func setupViews() {
        configureImageView()
        configureBadgeView()
        
        selectedOverlay.backgroundColor = UIColor.blue.withAlphaComponent(0.3)
        selectedOverlay.isHidden = true
        contentView.addSubview(selectedOverlay)
        selectedOverlay.frame = contentView.bounds
    }
    
    internal func configureImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        imageView.frame = contentView.bounds
    }
    
    internal func configureBadgeView() {
        badgeView = ZZAPSelectionIndexBadgeView()
        contentView.addSubview(badgeView)
        badgeView.delegate = self
        badgeView.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(6)
            make.width.height.equalTo(kZZAPSelectionIndexBadgeViewRadius * 2)
        }
    }
    // MARK: - UICollectionViewCell Lifecycle
    
    /// Prepare the cell for reuse, cancel any pending image request and reset badge
    public override func prepareForReuse() {
        self.badgeView.index = 0
        asset?.cancelImageRequest(requestID: requestID)
        if clearWhenPreparingForReuse {
            imageView.image = nil
        }
        self.mediaSubtypeBadgeOption = .none
    }
    
    
    // MARK: - Configuration
    
    /// Configure the cell with a PHAsset, request thumbnail image
    /// - Parameter asset: The asset to display
    public func configure(with asset: ZZAPAsset) {
        self.asset = asset
        let targetSize = CGSize(width: bounds.width * UIScreen.main.scale,
                                height: bounds.height * UIScreen.main.scale)
        
        self.requestID = asset.requestImage(targetSize: targetSize, completion: { [weak self] image in
            guard let self = self else { return }
            if self.asset?.id == asset.id {
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        })
    }
    
    public func update(updateOption: ZZAPAssetCellUpdateOption) {
        if updateOption.contains(option: .thumbnail) {
            if let asset = asset {
                let targetSize = CGSize(width: bounds.width * UIScreen.main.scale,
                                        height: bounds.height * UIScreen.main.scale)
                self.requestID = asset.requestImage(targetSize: targetSize, completion: { [weak self] image in
                    guard let self = self else { return }
                    if self.asset?.id == asset.id {
                        DispatchQueue.main.async {
                            self.imageView.image = image
                        }
                    }
                })
            }
        }
        
        if updateOption.contains(option: .badge) {
            self.updateSelectionMode(self.selectionMode, index: self.selectedIndex)
        }
    }
    
    // MARK: - Public Accessors
    
    /// Returns the current thumbnail image displayed
    public var thumbnailImage: UIImage? {
        return imageView.image
    }
    
    /// Returns the frame of the imageView relative to the window
    public var contentFrameInWindow: CGRect {
        return imageView.superview?.convert(imageView.frame, to: nil) ?? .zero
    }
    
    
    // MARK: - Selection Updates
    
    /// Update the selection mode and index on the badge view
    /// - Parameters:
    ///   - mode: Selection mode to update
    ///   - index: Selected index value
    public func updateSelectionMode(_ mode: ZZAPSelectionMode, index: Int) {
        badgeView.selectionMode = mode
        badgeView.index = index
    }
    
    /// Update the image zoom effect based on selection state
    /// - Parameter animated: Whether to animate the zoom transition
    private func updateImageSelection(animated: Bool) {
        let shouldZoomIn = selectedIndex != 0
        let targetRect: CGRect = shouldZoomIn
            ? CGRect(x: 0.05, y: 0.05, width: 0.9, height: 0.9)
            : CGRect(x: 0, y: 0, width: 1, height: 1)
        
        if animated {
            animateContentsRect(from: imageView.layer.contentsRect, to: targetRect)
        } else {
            imageView.layer.removeAnimation(forKey: "zoomAnimation")
            imageView.layer.contentsRect = targetRect
        }
    }
    
    /// Animate the imageView layer's contentsRect property for zoom effect
    /// - Parameters:
    ///   - from: Starting contentsRect
    ///   - to: Ending contentsRect
    private func animateContentsRect(from: CGRect, to: CGRect) {
        let animation = CABasicAnimation(keyPath: "contentsRect")
        animation.fromValue = from
        animation.toValue = to
        animation.duration = 0.25
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        imageView.layer.add(animation, forKey: "zoomAnimation")
        imageView.layer.contentsRect = to
    }
    
    
    // MARK: - ZZAPSelectionBadgeViewDelegate
    
    /// Called when the badge view is tapped
    public func badgeViewDidTap(_ badgeView: ZZAPSelectionBadgeViewProtocol) {
        self.shouldAnimateNextUpdate = true
        print("Tapped badgeView on asset: \(String(describing: asset?.id))")
        self.delegate?.assetCell(self, didTapBadgeFor: self.asset)
    }
    
    /// Called when the badge view is long pressed
    public func badgeViewDidLongPress(_ badgeView: ZZAPSelectionBadgeViewProtocol) {
        self.shouldAnimateNextUpdate = true
        print("Long-pressed badgeView on asset: \(String(describing: asset?.id))")
    }
}
