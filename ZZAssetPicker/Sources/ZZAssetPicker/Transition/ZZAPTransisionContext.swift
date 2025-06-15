//
//  ZZAPTransisionContext.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/15/25.
//

import Foundation
import Photos
import UIKit

@objc
public class ZZAPTransitionContext: NSObject {
    
    /// The image used as the starting point of the transition animation
    @objc public let fromImage: UIImage?
    
    /// The frame (position and size) from which the transition animation starts
    @objc public let fromFrame: CGRect
    
    /// Closure called before the transition animation begins
    @objc public var willBeginTransition: (() -> Void)?
    
    /// Closure called after the transition animation finishes
    /// - Parameter completed: Whether the transition completed successfully
    @objc public var didFinishTransition: ((_ completed: Bool) -> Void)?
    
    /// Designated initializer for creating a transition context
    /// - Parameters:
    ///   - fromImage: The starting image for the transition animation
    ///   - fromFrame: The starting frame for the transition animation
    ///   - willBeginTransition: Optional closure called before transition begins
    ///   - didFinishTransition: Optional closure called after transition ends
    @objc public init(fromImage: UIImage?, fromFrame: CGRect, willBeginTransition: (() -> Void)? = nil, didFinishTransition: ((_: Bool) -> Void)? = nil) {
        self.fromImage = fromImage
        self.fromFrame = fromFrame
        self.willBeginTransition = willBeginTransition
        self.didFinishTransition = didFinishTransition
    }
}
