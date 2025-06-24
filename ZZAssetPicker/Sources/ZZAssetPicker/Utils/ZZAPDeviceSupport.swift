//
//  ZZAPDeviceSupport.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/25/25.
//

import UIKit
import Foundation

@objcMembers
public class ZZAPDeviceSupport: NSObject {

    public static var supportsBlurEffect: Bool {
        var systemInfo = utsname()
        uname(&systemInfo)

        let machine = withUnsafePointer(to: &systemInfo.machine) {
            ptr in String(cString: UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self))
        }

        if machine.hasPrefix("iPhone") {
            let versionPart = machine.dropFirst("iPhone".count)
            let majorStr = versionPart.split(separator: ",").first ?? "0"
            if let major = Int(majorStr) {
                return major >= 14 // iPhone14,x → iPhone 13+
            }
            return false
        }

        if machine.hasPrefix("iPad") {
            let versionPart = machine.dropFirst("iPad".count)
            let majorStr = versionPart.split(separator: ",").first ?? "0"
            if let major = Int(majorStr) {
                return major >= 11 // iPad11,x → iPad 8
            }
            return false
        }

        return true
    }
}
