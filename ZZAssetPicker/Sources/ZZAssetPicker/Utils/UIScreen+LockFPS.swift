//
//  UIScreen+LockFPS.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 7/12/25.
//

import UIKit

import UIKit

public extension UIScreen {
    
    /// Lock the screen refresh rate to 120 fps if supported.
    /// Returns true if successfully locked.
    @discardableResult
    func lockTo120FPS() -> Bool {
        guard maximumFramesPerSecond >= 120 else { return false }
        FrameRateLocker.shared.lockFrameRate(120)
        return true
    }
    
    /// Lock the screen refresh rate to 60 fps.
    /// Returns true if successfully locked.
    @discardableResult
    func lockTo60FPS() -> Bool {
        FrameRateLocker.shared.lockFrameRate(60)
        return true
    }
    
    /// Unlock the frame rate to system default.
    func unlockFrameRate() {
        FrameRateLocker.shared.unlock()
    }
}

private class FrameRateLocker {
    @MainActor static let shared = FrameRateLocker()
    
    private var displayLink: CADisplayLink?
    
    func lockFrameRate(_ fps: Int) {
        displayLink?.invalidate()
        displayLink = nil
        
        guard fps > 0 else { return }
        
        displayLink = CADisplayLink(target: self, selector: #selector(dummyUpdate))
        if #available(iOS 15.0, *) {
            displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: Float(fps),
                                                                   maximum: Float(fps),
                                                                   preferred: Float(fps))
        } else {
            displayLink?.preferredFramesPerSecond = fps
        }
        displayLink?.add(to: .main, forMode: .common)
    }
    
    func unlock() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func dummyUpdate(link: CADisplayLink) {
        // Intentionally left empty to just keep the CADisplayLink alive
    }
}
