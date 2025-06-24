//
//  ZZAssetPickerViewController.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/25/25.
//

import Foundation
import UIKit
import Photos

@objc
public class ZZAssetPickerViewController: ZZAPAssetSelectionPolyViewController {
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public private(set) var config: ZZAssetPickerConfiguration
    
    public init(config: ZZAssetPickerConfiguration) {
        self.config = config
        
        var tabTypes = config.uiElementsConfig.tabTypes
        var selectionController = ZZAPSelectionControllerCommon(validationManager: nil, selectionMode: config.selectionConfig.selectionMode, maximumSelection: config.selectionConfig.maximumSelection)
        
        super.init(tabTypes: tabTypes, selectionController: selectionController, pageViewControllers: [])
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
