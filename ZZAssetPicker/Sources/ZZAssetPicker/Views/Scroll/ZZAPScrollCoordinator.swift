//
//  ZZAPScrollCoordinator.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 7/12/25.
//

import UIKit

@MainActor
class ZZAPScrollCoordinator: NSObject {
    weak var tabView: ZZAPTabView?
    weak var scrollView: UIScrollView?

    init(tabView: ZZAPTabView, scrollView: UIScrollView) {
        super.init()
        self.tabView = tabView
        self.scrollView = scrollView
        self.tabView?.delegate = self
        self.scrollView?.delegate = self
    }
}

extension ZZAPScrollCoordinator: ZZAPTabViewDelegate {
    @MainActor
    func tabView(_ tabView: ZZAPTabView, didSelect index: Int) {
        guard let scrollView = scrollView else { return }
        let offset = CGPoint(x: CGFloat(index) * scrollView.bounds.width, y: 0)
        scrollView.setContentOffset(offset, animated: true)
    }
}

extension ZZAPScrollCoordinator: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.bounds.width
        guard pageWidth > 0 else { return }

        let progress = scrollView.contentOffset.x / pageWidth
        let index = Int(floor(progress))
        let relativeProgress = progress - CGFloat(index) // 0.0 ~ 1.0
        let centeredProgress = relativeProgress <= 0.5 ? relativeProgress : relativeProgress - 1
        let targetIndex = relativeProgress <= 0.5 ? index : index + 1

        tabView?.scrollViewDidScroll(index: targetIndex, progress: centeredProgress)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        tabView?.setSelectedIndex(index, animated: true)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let index = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        tabView?.setSelectedIndex(index, animated: true)
    }
    
    /// Public method to programmatically switch tab and page
    public func selectTab(at index: Int, animated: Bool) {
        tabView?.setSelectedIndex(index, animated: animated)

        guard let scrollView = scrollView else { return }
        let offset = CGPoint(x: CGFloat(index) * scrollView.bounds.width, y: 0)
        scrollView.setContentOffset(offset, animated: animated)
    }
}
