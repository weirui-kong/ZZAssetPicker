//
//  ZZAPTipView.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 7/13/25.
//

import UIKit
import SnapKit

class ZZAPTipView: UIView {

    enum ArrowDirection {
        case up, down, left, right, center
    }

    private let label = UILabel()
    private let arrowSize = CGSize(width: 12, height: 8)
    private let padding: CGFloat = 12
    private let minWidth: CGFloat = 100
    private let maxWidth: CGFloat = 300
    private let edgeMargin: CGFloat = 18
    private let cornerRadius: CGFloat = 8

    private weak var targetView: UIView?
    private var arrowDirection: ArrowDirection = .center
    private var dismissTimer: Timer?
    private var arrowOffset: CGFloat = 0

    init(targetView: UIView, message: String) {
        super.init(frame: .zero)
        self.targetView = targetView
        setupView(message: message)
        calculatePosition()
        setupConstraints()
        setupAutoDismiss()
    }

    private func setupView(message: String) {
        backgroundColor = .clear
        isOpaque = false
        
        label.text = message
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        addSubview(label)
        
        guard let window = targetView?.window else { return }
        window.addSubview(self)
    }

    private func calculatePosition() {
        guard let targetView = targetView, let window = window else { return }
        
        let maxTextWidth = maxWidth - padding * 2
        let labelSize = label.sizeThatFits(CGSize(width: maxTextWidth, height: CGFloat.greatestFiniteMagnitude))
        let contentWidth = min(max(labelSize.width + padding * 2, minWidth), maxWidth)
        let contentHeight = labelSize.height + padding * 2
        
        let screenBounds = UIScreen.main.bounds.insetBy(dx: edgeMargin, dy: edgeMargin)
        let targetFrame = targetView.convert(targetView.bounds, to: window)
        
        let tipWidth = contentWidth
        let tipHeight = contentHeight + arrowSize.height
        
        arrowDirection = determineArrowDirection(targetFrame: targetFrame, screenBounds: screenBounds, tipSize: CGSize(width: tipWidth, height: tipHeight))
        
        let tipPosition = calculateTipPosition(targetFrame: targetFrame, screenBounds: screenBounds, tipSize: CGSize(width: tipWidth, height: tipHeight))
        
        arrowOffset = calculateArrowOffset(targetFrame: targetFrame, tipPosition: tipPosition, tipSize: CGSize(width: tipWidth, height: tipHeight))
        
        self.frame = CGRect(origin: tipPosition, size: CGSize(width: tipWidth, height: tipHeight))
    }

    private func determineArrowDirection(targetFrame: CGRect, screenBounds: CGRect, tipSize: CGSize) -> ArrowDirection {
        let spaceAbove = targetFrame.minY - screenBounds.minY
        let spaceBelow = screenBounds.maxY - targetFrame.maxY
        let spaceLeft = targetFrame.minX - screenBounds.minX
        let spaceRight = screenBounds.maxX - targetFrame.maxX
        
        if spaceBelow >= tipSize.height {
            return .up
        } else if spaceAbove >= tipSize.height {
            return .down
        } else if spaceRight >= tipSize.width {
            return .left
        } else if spaceLeft >= tipSize.width {
            return .right
        } else {
            return .center
        }
    }

    private func calculateTipPosition(targetFrame: CGRect, screenBounds: CGRect, tipSize: CGSize) -> CGPoint {
        var tipX: CGFloat = 0
        var tipY: CGFloat = 0
        
        switch arrowDirection {
        case .up:
            tipX = targetFrame.midX - tipSize.width / 2
            tipY = targetFrame.maxY
        case .down:
            tipX = targetFrame.midX - tipSize.width / 2
            tipY = targetFrame.minY - tipSize.height
        case .left:
            tipX = targetFrame.maxX
            tipY = targetFrame.midY - tipSize.height / 2
        case .right:
            tipX = targetFrame.minX - tipSize.width
            tipY = targetFrame.midY - tipSize.height / 2
        case .center:
            tipX = screenBounds.midX - tipSize.width / 2
            tipY = screenBounds.midY - tipSize.height / 2
        }
        
        tipX = max(screenBounds.minX, min(tipX, screenBounds.maxX - tipSize.width))
        tipY = max(screenBounds.minY, min(tipY, screenBounds.maxY - tipSize.height))
        
        return CGPoint(x: tipX, y: tipY)
    }

    private func calculateArrowOffset(targetFrame: CGRect, tipPosition: CGPoint, tipSize: CGSize) -> CGFloat {
        switch arrowDirection {
        case .up, .down:
            let targetCenterX = targetFrame.midX
            let tipCenterX = tipPosition.x + tipSize.width / 2
            let offset = targetCenterX - tipCenterX
            return tipSize.width / 2 + offset
        case .left, .right:
            let targetCenterY = targetFrame.midY
            let tipCenterY = tipPosition.y + tipSize.height / 2
            let offset = targetCenterY - tipCenterY
            return tipSize.height / 2 + offset
        case .center:
            return tipSize.width / 2
        }
    }

    private func setupConstraints() {
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview().offset(padding)
            make.right.lessThanOrEqualToSuperview().offset(-padding)
            make.top.greaterThanOrEqualToSuperview().offset(padding)
            make.bottom.lessThanOrEqualToSuperview().offset(-padding)
        }
    }

    private func setupAutoDismiss() {
        self.alpha = 0
        self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
            self.transform = .identity
        }
        
        dismissTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.dismiss()
            }
        }
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setFillColor(UIColor.zzapThemeColor.cgColor)
        
        let path = UIBezierPath()
        
        var bubbleRect = rect
        switch arrowDirection {
        case .up:
            bubbleRect = CGRect(x: 0, y: arrowSize.height, width: rect.width, height: rect.height - arrowSize.height)
        case .down:
            bubbleRect = CGRect(x: 0, y: 0, width: rect.width, height: rect.height - arrowSize.height)
        case .left:
            bubbleRect = CGRect(x: arrowSize.height, y: 0, width: rect.width - arrowSize.height, height: rect.height)
        case .right:
            bubbleRect = CGRect(x: 0, y: 0, width: rect.width - arrowSize.height, height: rect.height)
        case .center:
            bubbleRect = rect
        }
        
        let roundedRectPath = UIBezierPath(roundedRect: bubbleRect, cornerRadius: cornerRadius)
        path.append(roundedRectPath)
        
        if arrowDirection != .center {
            let arrowPath = UIBezierPath()
            
            switch arrowDirection {
            case .up:
                let tipX = arrowOffset
                arrowPath.move(to: CGPoint(x: tipX - arrowSize.width / 2, y: arrowSize.height))
                arrowPath.addLine(to: CGPoint(x: tipX + arrowSize.width / 2, y: arrowSize.height))
                arrowPath.addLine(to: CGPoint(x: tipX, y: 0))
                
            case .down:
                let tipX = arrowOffset
                arrowPath.move(to: CGPoint(x: tipX - arrowSize.width / 2, y: rect.height - arrowSize.height))
                arrowPath.addLine(to: CGPoint(x: tipX + arrowSize.width / 2, y: rect.height - arrowSize.height))
                arrowPath.addLine(to: CGPoint(x: tipX, y: rect.height))
                
            case .left:
                let tipY = arrowOffset
                arrowPath.move(to: CGPoint(x: arrowSize.height, y: tipY - arrowSize.width / 2))
                arrowPath.addLine(to: CGPoint(x: arrowSize.height, y: tipY + arrowSize.width / 2))
                arrowPath.addLine(to: CGPoint(x: 0, y: tipY))
                
            case .right:
                let tipY = arrowOffset
                arrowPath.move(to: CGPoint(x: rect.width - arrowSize.height, y: tipY - arrowSize.width / 2))
                arrowPath.addLine(to: CGPoint(x: rect.width - arrowSize.height, y: tipY + arrowSize.width / 2))
                arrowPath.addLine(to: CGPoint(x: rect.width, y: tipY))
                
            case .center:
                break
            }
            
            arrowPath.close()
            path.append(arrowPath)
        }
        
        path.fill()
    }

    func dismiss() {
        dismissTimer?.invalidate()
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            self.removeFromSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
