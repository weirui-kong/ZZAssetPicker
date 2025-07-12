//
//  UICollectionView+ZZAP.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 7/12/25.
//

import UIKit
import ObjectiveC

extension UICollectionView {

    // MARK: - Associated Keys

    private static var isAnimatingKey: UInt8 = 0
    private static var snapshotViewsKey: UInt8 = 1
    private static var transitionContainerKey: UInt8 = 2
    private static var convergeStartTimeKey: UInt8 = 3

    // MARK: - Associated Properties

    private var zzap_isAnimating: Bool {
        get { objc_getAssociatedObject(self, &Self.isAnimatingKey) as? Bool ?? false }
        set { objc_setAssociatedObject(self, &Self.isAnimatingKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    private var zzap_snapshotViews: [UIView] {
        get { objc_getAssociatedObject(self, &Self.snapshotViewsKey) as? [UIView] ?? [] }
        set { objc_setAssociatedObject(self, &Self.snapshotViewsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    private var zzap_transitionContainer: UIView? {
        get { objc_getAssociatedObject(self, &Self.transitionContainerKey) as? UIView }
        set { objc_setAssociatedObject(self, &Self.transitionContainerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    private var zzap_convergeStartTime: Date? {
        get { objc_getAssociatedObject(self, &Self.convergeStartTimeKey) as? Date }
        set { objc_setAssociatedObject(self, &Self.convergeStartTimeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    // MARK: - Private Cleanup Method
    
    private func zzap_cleanupPreviousAnimation() {
        self.zzap_snapshotViews.forEach { $0.removeFromSuperview() }
        self.zzap_snapshotViews = []
        self.zzap_transitionContainer?.removeFromSuperview()
        self.zzap_transitionContainer = nil
        self.layer.removeAllAnimations()
        self.zzap_convergeStartTime = nil
    }

    // MARK: - Public API

    func zzap_convergeToCenter() {
        guard zzap_isFullyVisibleInWindow() else { return }
        guard let superview = self.superview else { return }
        
        zzap_cleanupPreviousAnimation()
        
        self.zzap_convergeStartTime = Date()
        zzap_isAnimating = true

        let overlay = UIView(frame: self.frame)
        overlay.backgroundColor = .clear
        superview.insertSubview(overlay, aboveSubview: self)
        self.zzap_transitionContainer = overlay

        let centerPoint = CGPoint(x: overlay.bounds.midX, y: overlay.bounds.midY)
        var snapshots: [UIView] = []

        let visibleCells = self.visibleCells.sorted { $0.frame.minX < $1.frame.minX }
        let angleStep = CGFloat.pi / CGFloat(max(visibleCells.count - 1, 1))
        let baseAngle = -CGFloat.pi / 2

        for cell in visibleCells {
            guard let snapshot = cell.snapshotView(afterScreenUpdates: false) else { continue }
            snapshot.frame = overlay.convert(cell.frame, from: self)
            overlay.addSubview(snapshot)
            snapshots.append(snapshot)
        }

        self.isHidden = true
        self.zzap_snapshotViews = snapshots

        for (index, snapshot) in snapshots.enumerated() {
            let delay = Double(index) * 0.1 / Double(snapshots.count)
            
            UIView.animate(
                withDuration: 10,
                delay: delay,
                usingSpringWithDamping: 0.15,
                initialSpringVelocity: 0.9,
                options: [.curveEaseInOut, .allowUserInteraction],
                animations: {
                    let angle = baseAngle + CGFloat(index) * angleStep
                    let rotation = CGAffineTransform(rotationAngle: angle)
                    let translation = CGAffineTransform(
                        translationX: centerPoint.x - snapshot.center.x,
                        y: centerPoint.y - snapshot.center.y
                    )
                    snapshot.transform = rotation.concatenating(translation)
                    snapshot.alpha = 0.8
                },
                completion: { _ in
                    if index == snapshots.count - 1 {
                        if self.zzap_isAnimating {
                            self.zzap_isAnimating = false
                        }
                    }
                }
            )
        }

    }

    func zzap_restoreFromConvergence() {
        if let startTime = self.zzap_convergeStartTime {
            let elapsedTime = Date().timeIntervalSince(startTime)
            if elapsedTime < 0.8 {
                let delay = 0.8 - elapsedTime
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                    self?.zzap_restoreFromConvergence()
                }
                return
            }
        }
        
        guard !zzap_snapshotViews.isEmpty else { return }
        
        self.zzap_convergeStartTime = nil
        zzap_isAnimating = true
        
        let snapshots = self.zzap_snapshotViews

        for snapshot in snapshots {
            if let presentationLayer = snapshot.layer.presentation() {
                snapshot.transform = presentationLayer.transform.toCGAffineTransform()
            }
        }
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: [.curveEaseInOut, .beginFromCurrentState],
                       animations: {
            for snapshot in snapshots {
                snapshot.transform = .identity
                snapshot.alpha = 0
            }
        }, completion: { _ in
            self.isHidden = false
            self.zzap_cleanupPreviousAnimation()
            self.zzap_isAnimating = false
        })
    }
}

//
//extension CATransform3D {
//    func toCGAffineTransform() -> CGAffineTransform {
//        return CATransform3DGetAffineTransform(self)
//    }
//}
//
//extension UICollectionView {
//
//    // MARK: - Associated Keys
//
//    private static var isAnimatingKey: UInt8 = 0
//    private static var snapshotViewsKey: UInt8 = 1
//    private static var transitionContainerKey: UInt8 = 2
//
//    // MARK: - Associated Properties
//
//    private var zzap_isAnimatingExplosion: Bool {
//        get { objc_getAssociatedObject(self, &Self.isAnimatingKey) as? Bool ?? false }
//        set { objc_setAssociatedObject(self, &Self.isAnimatingKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
//    }
//
//    private var zzap_snapshotViews: [UIView] {
//        get { objc_getAssociatedObject(self, &Self.snapshotViewsKey) as? [UIView] ?? [] }
//        set { objc_setAssociatedObject(self, &Self.snapshotViewsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
//    }
//
//    private var zzap_transitionContainer: UIView? {
//        get { objc_getAssociatedObject(self, &Self.transitionContainerKey) as? UIView }
//        set { objc_setAssociatedObject(self, &Self.transitionContainerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
//    }
//
//    // MARK: - Public API
//
//    func zzap_convergeToCenter() {
//        guard !zzap_isAnimatingExplosion else { return }
//        guard let superview = self.superview else { return }
//        guard self.window != nil else { return }
//
//        zzap_isAnimatingExplosion = true
//
//        // 1. 创建与 collectionView 尺寸相同的容器
//        let overlay = UIView(frame: self.frame)
//        overlay.backgroundColor = .clear
//        superview.insertSubview(overlay, aboveSubview: self)
//        self.zzap_transitionContainer = overlay
//
//        let centerPoint = CGPoint(x: overlay.bounds.midX, y: overlay.bounds.midY)
//        var snapshots: [UIView] = []
//
//        let visibleCells = self.visibleCells.sorted { $0.frame.minX < $1.frame.minX }
//        let angleStep = CGFloat.pi / CGFloat(max(visibleCells.count - 1, 1))
//        let baseAngle = -CGFloat.pi / 2
//
//        for (index, cell) in visibleCells.enumerated() {
//            guard let snapshot = cell.snapshotView(afterScreenUpdates: false) else { continue }
//            let relativeFrame = overlay.convert(cell.frame, from: self)
//            snapshot.frame = relativeFrame
//            overlay.addSubview(snapshot)
//            snapshots.append(snapshot)
//        }
//
//        self.isHidden = true
//        self.zzap_snapshotViews = snapshots
//
//        UIView.animate(withDuration: 1.5,
//                       delay: 0,
//                       usingSpringWithDamping: 0.35,
//                       initialSpringVelocity: 0.7,
//                       options: [.curveEaseInOut],
//                       animations: {
//            for (index, snapshot) in snapshots.enumerated() {
//                let angle = baseAngle + CGFloat(index) * angleStep
//                let rotation = CGAffineTransform(rotationAngle: angle)
//                let translation = CGAffineTransform(
//                    translationX: centerPoint.x - snapshot.center.x,
//                    y: centerPoint.y - snapshot.center.y
//                )
//                snapshot.transform = rotation.concatenating(translation)
//                snapshot.alpha = 0.95
//            }
//        }, completion: { _ in
//            self.zzap_isAnimatingExplosion = false
//        })
//    }
//
//    func zzap_restoreFromConvergence() {
//        
//        guard !zzap_isAnimatingExplosion else {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
//                self?.zzap_restoreFromConvergence()
//            }
//            return
//        }
//        zzap_isAnimatingExplosion = true
//
//        let snapshots = self.zzap_snapshotViews
//
//        // Use presentation transform for smoothness
//        for snapshot in snapshots {
//            if let presLayer = snapshot.layer.presentation() {
//                snapshot.transform = presLayer.transform.toCGAffineTransform()
//            }
//        }
//
//        UIView.animate(withDuration: 0.5, animations: {
//            for snapshot in snapshots {
//                snapshot.transform = .identity
//                snapshot.alpha = 0
//            }
//        }, completion: { _ in
//            // 清理 snapshot 和容器
//            for snapshot in snapshots {
//                snapshot.removeFromSuperview()
//            }
//
//            self.zzap_snapshotViews = []
//            self.zzap_transitionContainer?.removeFromSuperview()
//            self.zzap_transitionContainer = nil
//
//            self.isHidden = false
//            self.zzap_isAnimatingExplosion = false
//        })
//    }
//}
