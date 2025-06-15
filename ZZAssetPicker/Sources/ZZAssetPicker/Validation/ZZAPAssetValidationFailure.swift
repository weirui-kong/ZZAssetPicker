//
//  ZZAPAssetValidationFailure.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/14/25.
//

import Foundation

/// Represents a validation failure with a code, message, and optional extra info.
/// This object describes why an asset failed validation.
@objc public class ZZAPAssetValidationFailure: NSObject {
    /// Error code string identifying failure type.
    @objc public let code: String
    
    /// Human-readable message describing the failure.
    @objc public let message: String
    
    /// Optional additional data related to failure.
    @objc public let extra: [String: Any]?
    
    /// Initialize a validation failure object.
    /// - Parameters:
    ///   - code: Error code string.
    ///   - message: Description of the failure.
    ///   - extra: Optional extra information dictionary.
    @objc public init(code: String, message: String, extra: [String: Any]? = nil) {
        self.code = code
        self.message = message
        self.extra = extra
    }
}
