//
//  ZZAPImageCell.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/14/25.
//

import Foundation
import UIKit
import Photos
import SnapKit

@objcMembers
public class ZZAPImageCell: ZZAPAssetCellBase {
    
    // MARK: - Live Photo Icon
    
    /// Icon displayed for Live Photo assets
    private let livePhotoIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(zzap_named: "livephoto", tintColor: .white)
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    // MARK: - Reuse Identifier
    
    /// Cell reuse identifier override
    override public class var reuseIdentifier: String {
        return "ZZAPImageCell"
    }
    
    // MARK: - Initialization
    
    /// Initialize cell and setup live photo icon
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLivePhotoIcon()
    }
    
    /// Not implemented
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// Add and layout the live photo icon in content view
    private func setupLivePhotoIcon() {
        contentView.addSubview(livePhotoIcon)
        livePhotoIcon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().offset(-4)
            make.size.equalTo(16)
        }
    }
    
    // MARK: - Configuration
    
    /// Configure cell with asset and update live photo icon visibility
    /// - Parameter asset: The PHAsset to configure
    public override func configure(with asset: ZZAPAsset) {
        super.configure(with: asset)
        livePhotoIcon.isHidden = !((asset.mediaSubtypes?.contains(.photoLive) ?? true) && self.mediaSubtypeBadgeOption.contains(option: .livePhoto))
    }
    
    // MARK: - Prepare for Reuse
    
    /// Reset live photo icon visibility on reuse
    public override func prepareForReuse() {
        super.prepareForReuse()
        livePhotoIcon.isHidden = true
    }
}
