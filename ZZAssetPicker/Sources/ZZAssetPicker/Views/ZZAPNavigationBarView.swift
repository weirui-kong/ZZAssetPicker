//
//  ZZAPNavigationBarView.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 7/12/25.
//

import UIKit
import SnapKit

public class ZZAPNavigationBarView: UIView {

    public let titleLabel = UILabel()
    public var leftButtons: [UIButton] = []
    public var rightButtons: [UIButton] = []

    private let leftStackView = UIStackView()
    private let rightStackView = UIStackView()

    public var barHeight: CGFloat = 44 {
        didSet {
            snp.updateConstraints { make in
                make.height.equalTo(barHeight)
            }
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .white

        // Title
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center

        // StackViews
        [leftStackView, rightStackView].forEach {
            $0.axis = .horizontal
            $0.spacing = 8
            $0.alignment = .center
            $0.distribution = .equalSpacing
        }

        addSubview(titleLabel)
        addSubview(leftStackView)
        addSubview(rightStackView)

        // Layout with SnapKit
        snp.makeConstraints { make in
            make.height.equalTo(barHeight)
        }

        leftStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.centerY.equalToSuperview()
        }

        rightStackView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(18 )
            make.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    public func setLeftButtons(_ buttons: [UIButton]) {
        leftButtons = buttons
        leftStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        buttons.forEach { leftStackView.addArrangedSubview($0) }
    }

    public func setRightButtons(_ buttons: [UIButton]) {
        rightButtons = buttons
        rightStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        buttons.forEach { rightStackView.addArrangedSubview($0) }
    }
}
