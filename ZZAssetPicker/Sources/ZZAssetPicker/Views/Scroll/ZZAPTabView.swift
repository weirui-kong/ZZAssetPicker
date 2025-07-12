//
//  ZZAPTabView.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 7/12/25.
//

import UIKit

@MainActor
@objc protocol ZZAPTabViewDelegate: AnyObject {
    func tabView(_ tabView: ZZAPTabView, didSelect index: Int)
}

class ZZAPTabView: UIView {

    weak var delegate: ZZAPTabViewDelegate?

    private(set) var selectedIndex: Int = 0
    private(set) var tabTitles: [String] = []

    private var buttons: [UIButton] = []
    private let indicator = UIView()
    private let stackView = UIStackView()

    private let indicatorHeight: CGFloat = 3
    private let indicatorCornerRadius: CGFloat = 1.5
    private let activeColor = UIColor.zzapThemeColor
    private let inactiveColor = UIColor.lightGray
    private let selectedScale: CGFloat = 1.0
    private let deselectedScale: CGFloat = 0.9

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill

        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -indicatorHeight)
        ])

        indicator.backgroundColor = activeColor
        indicator.layer.cornerRadius = indicatorCornerRadius
        addSubview(indicator)
    }

    public func setupTabs(tabs: [ZZAPTabType]) {
        tabTitles = tabs.map { $0.localizedString }
        buttons.forEach { $0.removeFromSuperview() }
        buttons = []

        for (index, title) in tabTitles.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.setTitleColor(inactiveColor, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
            button.tag = index
            button.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
            button.transform = CGAffineTransform(scaleX: deselectedScale, y: deselectedScale)
            stackView.addArrangedSubview(button)
            buttons.append(button)
        }

        layoutIfNeeded()
        setSelectedIndex(0, animated: false)
    }

    public func setSelectedIndex(_ index: Int, animated: Bool) {
        guard index >= 0 && index < buttons.count else { return }
        selectedIndex = index
        updateIndicator(animated: animated)
        updateButtonStates(animated: animated)
    }

    @objc private func tabTapped(_ sender: UIButton) {
        setSelectedIndex(sender.tag, animated: true)
        delegate?.tabView(self, didSelect: sender.tag)
    }

    private func updateIndicator(animated: Bool) {
        guard buttons.indices.contains(selectedIndex) else { return }
        let button = buttons[selectedIndex]

        let indicatorWidth = min(button.frame.width * 0.25, 56)
        let indicatorFrame = CGRect(
            x: button.frame.minX + (button.frame.width - indicatorWidth) / 2,
            y: bounds.height - indicatorHeight,
            width: indicatorWidth,
            height: indicatorHeight
        )

        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut]) {
                self.indicator.frame = indicatorFrame
            }
        } else {
            indicator.frame = indicatorFrame
        }
    }

    private func updateButtonStates(animated: Bool) {
        for (index, button) in buttons.enumerated() {
            let isSelected = (index == selectedIndex)
            let color = isSelected ? activeColor : inactiveColor
            let scale = isSelected ? selectedScale : deselectedScale

            if animated {
                UIView.animate(withDuration: 0.25) {
                    button.setTitleColor(color, for: .normal)
                    button.transform = CGAffineTransform(scaleX: scale, y: scale)
                }
            } else {
                button.setTitleColor(color, for: .normal)
                button.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
    }

    // Update indicator and buttons during scroll progress
    public func scrollViewDidScroll(index: Int, progress: CGFloat) {
        let fromIndex: Int
        let toIndex: Int

        if progress >= 0 {
            fromIndex = index
            toIndex = index + 1
        } else {
            fromIndex = index
            toIndex = index - 1
        }

        guard buttons.indices.contains(fromIndex), buttons.indices.contains(toIndex) else { return }

        let fromButton = buttons[fromIndex]
        let toButton = buttons[toIndex]
        let absProgress = abs(progress)

        // Calculate width as 50% of button width or minimum 56pt
        let fromWidth = max(fromButton.frame.width * 0.5, 56)
        let toWidth = max(toButton.frame.width * 0.5, 56)

        // Calculate center X for indicator interpolation
        let fromCenterX = fromButton.frame.minX + fromButton.frame.width / 2
        let toCenterX = toButton.frame.minX + toButton.frame.width / 2
        let interpolatedCenterX = fromCenterX + (toCenterX - fromCenterX) * absProgress

        // Interpolate width
        let interpolatedWidth = fromWidth + (toWidth - fromWidth) * absProgress
        let indicatorX = interpolatedCenterX - interpolatedWidth / 2

        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut]) {
            self.indicator.frame = CGRect(
                x: indicatorX,
                y: self.bounds.height - self.indicatorHeight,
                width: interpolatedWidth,
                height: self.indicatorHeight
            )
        }

        // Animate button colors and scale during scroll
        for (i, button) in buttons.enumerated() {
            let scale: CGFloat
            let color: UIColor

            if i == fromIndex {
                scale = selectedScale - (selectedScale - deselectedScale) * absProgress
                color = interpolateColor(from: activeColor, to: inactiveColor, progress: absProgress)
            } else if i == toIndex {
                scale = deselectedScale + (selectedScale - deselectedScale) * absProgress
                color = interpolateColor(from: inactiveColor, to: activeColor, progress: absProgress)
            } else {
                scale = deselectedScale
                color = inactiveColor
            }

            button.setTitleColor(color, for: .normal)
            button.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }

    private func interpolateColor(from: UIColor, to: UIColor, progress: CGFloat) -> UIColor {
        var fromR: CGFloat = 0, fromG: CGFloat = 0, fromB: CGFloat = 0, fromA: CGFloat = 0
        var toR: CGFloat = 0, toG: CGFloat = 0, toB: CGFloat = 0, toA: CGFloat = 0

        from.getRed(&fromR, green: &fromG, blue: &fromB, alpha: &fromA)
        to.getRed(&toR, green: &toG, blue: &toB, alpha: &toA)

        let r = fromR + (toR - fromR) * progress
        let g = fromG + (toG - fromG) * progress
        let b = fromB + (toB - fromB) * progress
        let a = fromA + (toA - fromA) * progress

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
