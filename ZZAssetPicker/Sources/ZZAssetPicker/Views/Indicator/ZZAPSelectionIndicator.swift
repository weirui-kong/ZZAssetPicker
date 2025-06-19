//
//  ZZAPSelectionIndicator.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/19/25.
//

import UIKit
import Foundation

@MainActor
@objc
public protocol ZZAPSelectionIndicator: AnyObject {
    
    var selectionController: ZZAPSelectable? { get set }
    
    var delegate: ZZAPSelectableDelegate? { get set }

}
