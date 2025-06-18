//
//  ZZAPSelectionMode.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/14/25.
//

import Foundation

@objc public enum ZZAPSelectionMode: Int {
    /// No selection allowed
    case none
    
    /// Single selection mode - only one asset can be selected at a time
    case single
    
    /// Multiple selection mode - multiple assets can be selected
    case multipleCompact
    case multipleSparse
}
