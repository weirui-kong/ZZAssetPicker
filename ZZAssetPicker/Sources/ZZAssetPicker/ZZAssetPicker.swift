// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit
import SnapKit

@objc public class ZZAssetPickerViewController: UIViewController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let label = UILabel()
        label.text = "ZZAssetPicker"
        view.addSubview(label)
        label.snp.makeConstraints { $0.center.equalToSuperview() }
    }
}
