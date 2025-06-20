//
//  ZZAPIndicatorAssetCell.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/19/25.
//

import UIKit
import Photos
import Foundation
import SnapKit
@objcMembers
public class ZZAPIndicatorAssetCell: ZZAPAssetCellBase {
    
    private let blurView: UIVisualEffectView = {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        blur.layer.cornerRadius = 8
        return blur
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .white)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupPlaceholderUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPlaceholderUI() {
        contentView.addSubview(blurView)
        blurView.snp.makeConstraints { make in
            make.edges.equalTo(imageView)
        }

        blurView.contentView.addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    override internal func configureImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.left.bottom.equalTo(contentView)
            make.width.equalTo(contentView).offset(-0.75 * kZZAPSelectionShapeBadgeViewRadius)
            make.height.equalTo(contentView).offset(-0.75 * kZZAPSelectionShapeBadgeViewRadius)
        }
    }
    
    override internal func configureBadgeView() {
        badgeView = ZZAPSelectionShapeBadgeView()
        
        if #available(iOS 13.0, *), let badgeView = badgeView as? ZZAPSelectionShapeBadgeView {
            let config = UIImage.SymbolConfiguration(weight: .bold)
            badgeView.image = UIImage(systemName: "minus", withConfiguration: config)
        } else {
            assert(false, "pending fallback")
        }

        contentView.addSubview(badgeView)
        badgeView.delegate = self
        badgeView.isHidden = true

        badgeView.snp.makeConstraints { make in
            make.width.height.equalTo(kZZAPSelectionShapeBadgeViewRadius * 2)
            make.right.top.equalTo(contentView)
        }
    }

    private var isLoadingScheduled = false

    public override func configure(with asset: ZZAPAsset) {
        self.asset = asset
        self.badgeView.isHidden = true
        self.imageView.image = nil
        self.blurView.isHidden = true
        self.loadingIndicator.stopAnimating()
        self.isLoadingScheduled = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self = self else { return }
            if self.isLoadingScheduled {
                self.blurView.isHidden = false
                self.loadingIndicator.startAnimating()
            }
        }

        let targetSize = CGSize(width: bounds.width * UIScreen.main.scale,
                                height: bounds.height * UIScreen.main.scale)
        
        self.requestID = asset.requestImage(targetSize: targetSize) { [weak self] image in
            guard let self = self else { return }
            guard self.asset?.id == asset.id else { return }

            DispatchQueue.main.async {
                self.imageView.image = image
                self.isLoadingScheduled = false
                self.requestID = 0
                let success = image != nil
                if success {
                    self.blurView.isHidden = true
                    self.loadingIndicator.stopAnimating()
                    self.badgeView.isHidden = false
                }
            }
        }
    }
    
    public override func badgeViewDidTap(_ badgeView: any ZZAPSelectionBadgeViewProtocol) {
        delegate?.assetCell(self, didTapBadgeFor: asset)
    }
}
