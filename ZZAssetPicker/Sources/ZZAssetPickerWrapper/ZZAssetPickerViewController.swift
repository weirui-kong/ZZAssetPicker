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
    
    public init(config: ZZAssetPickerConfiguration) {
        var tabTypes = config.userInterfaceConfig.tabTypes
        
        var rules = [ZZAPAssetValidationRule]()
        rules.append(ZZAPResolutionRule.within(minWidth: config.selectionConfig.minimumSize.width,
                                               minHeight: config.selectionConfig.minimumSize.height,
                                               maxWidth: config.selectionConfig.maximumSize.width,
                                               maxHeight: config.selectionConfig.maximumSize.height))
        rules.append(ZZAPDurationRule.within(min: config.selectionConfig.minimumDuration, max: config.selectionConfig.maximumDuration))
        if config.selectionConfig.requireFaces {
            rules.append(ZZAPFaceDetectionRule(requireFace: true))
        }
        if config.selectionConfig.requireQrCodes {
            rules.append(ZZAPQRCodeDetectionRule(requireQRCode: true))
        }
        let validationManager = ZZAPAssetValidatorManager(rules: rules)
        var selectionController = ZZAPSelectionControllerCommon(validationManager: validationManager, selectionMode: config.selectionConfig.selectionMode, maximumSelection: config.selectionConfig.maximumSelection)
        
        super.init(config: config, tabTypes: tabTypes, selectionController: selectionController, pageViewControllers: [])
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
