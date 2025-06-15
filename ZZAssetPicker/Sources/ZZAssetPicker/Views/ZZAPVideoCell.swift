//
//  ZZAPVideoCell.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/14/25.
//

import Foundation
import UIKit
import Photos
import SnapKit

@objcMembers
public class ZZAPVideoCell: ZZAPAssetCellBase {
    
    // MARK: - Duration Label
    
    /// Label to display video duration
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 10)
        label.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    
    // MARK: - Reuse Identifier
    
    /// Reuse identifier for video cell
    override public class var reuseIdentifier: String {
        return "ZZAPVideoCell"
    }
    
    
    // MARK: - Initialization
    
    /// Initialize video cell and setup duration label
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDurationLabel()
    }
    
    /// Not implemented initializer
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Setup Views
    
    /// Add and layout the duration label in content view
    private func setupDurationLabel() {
        contentView.addSubview(durationLabel)
        durationLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-4)
            make.bottom.equalToSuperview().offset(-4)
            make.height.equalTo(16)
            make.width.greaterThanOrEqualTo(32)
        }
    }
    
    
    // MARK: - Prepare For Reuse
    
    /// Reset duration label on cell reuse
    public override func prepareForReuse() {
        super.prepareForReuse()
        durationLabel.text = "0:00"
    }
    
    
    // MARK: - Configuration
    
    /// Configure the cell with a PHAsset and update duration label
    /// - Parameter asset: The PHAsset representing the video
    public override func configure(with asset: PHAsset) {
        super.configure(with: asset)
        
        // Format the duration from seconds to "m:ss" string
        let duration = Int(asset.duration)
        let minutes = duration / 60
        let seconds = duration % 60
        durationLabel.text = String(format: "%d:%02d", minutes, seconds)
    }
}
