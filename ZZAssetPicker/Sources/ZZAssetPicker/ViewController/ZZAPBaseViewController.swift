//
//  ZZAPBaseViewController.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 7/12/25.
//

import UIKit
import SnapKit

@objcMembers
open class ZZAPBaseViewController: UIViewController {

    public let navigationBarView = ZZAPNavigationBarView()

    open var barHeight: CGFloat { 44 }

    open override func viewDidLoad() {
        super.viewDidLoad()

        if requiresNavigationBarView() {
            view.addSubview(navigationBarView)

            navigationBarView.snp.makeConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                make.left.right.equalToSuperview()
                make.height.equalTo(barHeight)
            }

            navigationBarView.titleLabel.text = navigationBarTitle()
            navigationBarView.setLeftButtons(navigationBarLeftButtons())
            navigationBarView.setRightButtons(navigationBarRightButtons())
        }
    }
}

extension ZZAPBaseViewController {
    open func requiresNavigationBarView() -> Bool {
        return false
    }

    open func navigationBarTitle() -> String? {
        return nil
    }

    open func navigationBarLeftButtons() -> [UIButton] {
        return []
    }

    open func navigationBarRightButtons() -> [UIButton] {
        return []
    }
    
    open var contentTopConstraintTarget: ConstraintRelatableTarget {
        if requiresNavigationBarView() {
            return navigationBarView.snp.bottom
        } else {
            return view.snp.top
        }
    }
}
