//
//  ZZAPSelectionBadgeViewProtocol.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/19/25.
//

import UIKit
import Foundation

@MainActor
@objc public protocol ZZAPSelectionBadgeViewDelegate: AnyObject {
    /// Called when badge view is tapped
    func badgeViewDidTap(_ badgeView: ZZAPSelectionBadgeViewProtocol)
    
    /// Called when badge view is long pressed
    func badgeViewDidLongPress(_ badgeView: ZZAPSelectionBadgeViewProtocol)
}

@MainActor
@objc
public protocol ZZAPSelectionBadgeViewProtocol: AnyObject {
    var selectionMode: ZZAPSelectionMode { get set }
    var index: Int { get set }
    var delegate: ZZAPSelectionBadgeViewDelegate? { get set }
}
