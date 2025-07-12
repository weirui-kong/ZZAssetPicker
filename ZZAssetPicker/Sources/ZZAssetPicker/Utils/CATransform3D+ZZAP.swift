//
//  CATransform3D+ZZAP.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 7/13/25.
//

import UIKit

extension CATransform3D {
    func toCGAffineTransform() -> CGAffineTransform {
        return CATransform3DGetAffineTransform(self)
    }
}
