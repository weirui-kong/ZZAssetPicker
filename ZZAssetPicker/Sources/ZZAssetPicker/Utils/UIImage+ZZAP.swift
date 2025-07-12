//
//  UIImage+ZZAP.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 7/12/25.
//

import UIKit

extension UIImage {

    convenience init?(zzap_named name: String?, tintColor: UIColor? = nil) {
        guard let name = name, !name.isEmpty else {
            let placeholder = UIImage.zzap_drawPlaceholder(text: "N/A", tintColor: tintColor)
            self.init(cgImage: placeholder.cgImage!)
            return
        }

        var image: UIImage?

        if #available(iOS 13.0, *) {
            if let sysImg = UIImage(systemName: name) {
                image = sysImg.withRenderingMode(.alwaysTemplate)
            }
        }

        if image == nil {
            image = UIImage(named: name)
        }

        if let image = image {
            if let tintColor = tintColor {
                let tinted = image.withRenderingMode(.alwaysTemplate)
                self.init(cgImage: UIImage.zzap_tintedImage(image: tinted, tintColor: tintColor).cgImage!)
            } else {
                self.init(cgImage: image.cgImage!)
            }
            return
        }

        // fallback placeholder
        let placeholder = UIImage.zzap_drawPlaceholder(text: name, tintColor: tintColor)
        self.init(cgImage: placeholder.cgImage!)
    }

    private static func zzap_tintedImage(image: UIImage, tintColor: UIColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { ctx in
            tintColor.set()
            ctx.fill(CGRect(origin: .zero, size: image.size))

            image.draw(at: .zero, blendMode: .destinationIn, alpha: 1)
        }
    }

    private static func zzap_drawPlaceholder(text: String, tintColor: UIColor? = nil) -> UIImage {
        let size = CGSize(width: 128, height: 128)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { ctx in
            UIColor.black.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            paragraphStyle.lineBreakMode = .byWordWrapping

            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: tintColor ?? UIColor.white,
                .paragraphStyle: paragraphStyle,
            ]

            let attrString = NSAttributedString(string: text, attributes: attrs)

            let textRect = CGRect(x: 4, y: 4, width: size.width - 8, height: size.height - 8)
            attrString.draw(with: textRect, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        }
    }
}
