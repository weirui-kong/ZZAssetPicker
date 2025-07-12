//
//  UIView+ZZAP.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 7/12/25.
//

import UIKit

extension UIView {
    func zzap_isFullyVisibleInWindow() -> Bool {
        guard let window = self.window else { return false }
        let convertedFrame = self.convert(self.bounds, to: window)
        return window.bounds.intersects(convertedFrame)
    }
    
    
}
