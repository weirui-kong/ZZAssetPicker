//
//  ZZAPSelectionControllerCommon.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/14/25.
//

import Foundation
import Photos
import UIKit

/// Default behavior: toggle for single, preview for multiple
@objc public final class ZZAPSelectionControllerCommon: ZZAPSelectionControllerBase {
    
    /// Handles tap on asset by showing preview.
    /// - Parameters:
    ///   - selectionContext: Context of the selected asset
    ///   - transitionContext: Context for animation and navigation
    @objc public override func didTapAsset(selectionContext: ZZAPSelectionContext?, transitionContext: ZZAPTransitionContext?) {
        self.preview(selectionContext: selectionContext, transitionContext: transitionContext)
    }
    
    // TODO: Dev code... will be removed later
    /// Shows a fullscreen animated preview of the asset's image.
    /// The image animates from its source frame to fullscreen with spring animation.
    /// After 2 seconds, the preview and background fade away.
    /// - Parameters:
    ///   - selectionContext: Context of the selected asset
    ///   - transitionContext: Context including source image and frame
    @objc public override func preview(selectionContext: ZZAPSelectionContext?, transitionContext: ZZAPTransitionContext?) {
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
