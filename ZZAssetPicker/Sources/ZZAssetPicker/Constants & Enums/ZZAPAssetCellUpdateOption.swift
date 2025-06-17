//
//  ZZAPAssetCellUpdateOption.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/18/25.
//

@objc
public enum ZZAPAssetCellUpdateOption: Int {
    case none      = 0
    case thumbnail = 1
    case badge     = 2
    case overlay   = 4
    
    public static let all: Int = ZZAPAssetCellUpdateOption.thumbnail.rawValue
    | ZZAPAssetCellUpdateOption.badge.rawValue
    | ZZAPAssetCellUpdateOption.overlay.rawValue
    
    public func contains(option: ZZAPAssetCellUpdateOption) -> Bool {
        return (self.rawValue & option.rawValue) != 0
    }
}
