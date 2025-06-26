//
//  Notification.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/26/25.
//

import Foundation

extension Notification.Name {
    public static let ZZAPSelectionDidChange = Notification.Name("ZZAPSelectionDidChangeNotification")
    public static let ZZAPValidationDidEnd   = Notification.Name("ZZAPValidationDidEndNotification")
    public static let ZZAPValidationDidStart = Notification.Name("ZZAPValidationDidStartNotification")
    public static let ZZAPValidationProgress = Notification.Name("ZZAPValidationProgressNotification")
    public static let ZZAPValidationShouldStop = Notification.Name("ZZAPValidationShouldStopNotification")
}
