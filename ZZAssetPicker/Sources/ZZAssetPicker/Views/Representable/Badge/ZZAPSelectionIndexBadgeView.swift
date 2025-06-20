//
//  ZZAPSelectionIndexBadgeView.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/15/25.
//

import UIKit
import SnapKit

public let kZZAPSelectionIndexBadgeViewRadius: CGFloat = 12.0

@objcMembers
public class ZZAPSelectionIndexBadgeView: UIView, ZZAPSelectionBadgeViewProtocol {
    
    // MARK: - Public Properties
    
    /// Delegate to handle tap and long press events
    public weak var delegate: ZZAPSelectionBadgeViewDelegate?
    
    /// Selection mode of the badge view (none, single, multiple)
    public var selectionMode: ZZAPSelectionMode = .none {
        didSet { refreshAppearance() }
    }
    
    /// Index number shown in the badge view (used in multiple selection mode)
    public var index: Int = 0 {
        didSet { refreshAppearance() }
    }
    
    // MARK: - Subviews
    
    private let outerCircle = UIView()
    private let innerCircle = UIView()
    private let indexLabel = UILabel()
    
    // MARK: - Private Properties
    
    /// Flag indicating whether next update should animate changes
    private var shouldAnimateNextUpdate = false
    
    // MARK: - Initialization
    
    /// Initialize badge view and setup UI & gestures
    public override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    /// Layout subviews and update corner radius to keep circles round
    public override func layoutSubviews() {
        super.layoutSubviews()
        outerCircle.layer.cornerRadius = outerCircle.bounds.width / 2
        innerCircle.layer.cornerRadius = innerCircle.bounds.width / 2
    }
    
    // MARK: - UI Setup
    
    /// Build UI components and add to view hierarchy
    private func buildUI() {
        setupOuterCircle()
        setupInnerCircle()
        setupIndexLabel()
    }
    
    /// Setup the outer circle with border and shadow
    private func setupOuterCircle() {
        addSubview(outerCircle)
        outerCircle.snp.makeConstraints { $0.edges.equalToSuperview() }
        outerCircle.layer.borderWidth = 1.75
        outerCircle.layer.borderColor = UIColor.white.cgColor
        outerCircle.layer.shadowColor = UIColor.black.cgColor
        outerCircle.layer.shadowOpacity = 0.15
        outerCircle.layer.shadowOffset = CGSize(width: 0, height: 1)
        outerCircle.layer.shadowRadius = 2
        outerCircle.backgroundColor = .white.withAlphaComponent(0.2)
    }
    
    /// Setup the inner circle with default background color
    private func setupInnerCircle() {
        outerCircle.addSubview(innerCircle)
        innerCircle.backgroundColor = .zzapThemeColor
    }
    
    /// Setup the index label for showing selection number
    private func setupIndexLabel() {
        outerCircle.addSubview(indexLabel)
        indexLabel.textColor = .white
        indexLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        indexLabel.textAlignment = .center
        indexLabel.adjustsFontSizeToFitWidth = true
        indexLabel.minimumScaleFactor = 0.5
        indexLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
    }
    
    // MARK: - Gesture Setup
    
    /// Setup tap and long press gesture recognizers
    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        addGestureRecognizer(longPress)
    }
    
    // MARK: - Appearance Update
    
    /// Refresh the badge view appearance based on selection mode and index
    private func refreshAppearance() {
        switch selectionMode {
        case .none:
            isHidden = true
            
        case .single:
            isHidden = false
            indexLabel.text = nil
            let targetSize = (kZZAPSelectionIndexBadgeViewRadius - 4) * 2
            let fromSize = (kZZAPSelectionIndexBadgeViewRadius - 6) * 2
            
            if index == 0 {
                if shouldAnimateNextUpdate {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.innerCircle.alpha = 0
                    }, completion: { _ in
                        self.innerCircle.isHidden = true
                    })
                } else {
                    innerCircle.alpha = 0
                    innerCircle.isHidden = true
                }
            } else {
                innerCircle.isHidden = false
                innerCircle.alpha = 1
                
                innerCircle.snp.remakeConstraints { make in
                    make.center.equalToSuperview()
                    make.width.height.equalTo(fromSize)
                }
                layoutIfNeeded()
                
                if shouldAnimateNextUpdate {
                    UIView.animate(
                        withDuration: 0.35,
                        delay: 0,
                        usingSpringWithDamping: 0.6,
                        initialSpringVelocity: 0.5,
                        options: [.curveEaseInOut],
                        animations: {
                            self.innerCircle.snp.updateConstraints { make in
                                make.width.height.equalTo(targetSize)
                            }
                            self.layoutIfNeeded()
                        },
                        completion: nil
                    )
                } else {
                    innerCircle.snp.updateConstraints { make in
                        make.width.height.equalTo(targetSize)
                    }
                    layoutIfNeeded()
                }
                
                innerCircle.layer.cornerRadius = (kZZAPSelectionIndexBadgeViewRadius - 4)
            }
        case .multipleCompact:
            fallthrough
        case .multipleSparse:
            isHidden = false
            
            if index > 0 {
                indexLabel.text = "\(index)"
                if shouldAnimateNextUpdate {
                    innerCircle.alpha = 0
                    innerCircle.isHidden = false
                    indexLabel.alpha = 0
                    indexLabel.isHidden = false
                    innerCircle.snp.remakeConstraints { make in
                        make.edges.equalToSuperview()
                    }
                    innerCircle.layer.cornerRadius = kZZAPSelectionIndexBadgeViewRadius
                    
                    UIView.animate(withDuration: 0.25) {
                        self.innerCircle.alpha = 1
                        self.indexLabel.alpha = 1
                    }
                } else {
                    innerCircle.isHidden = false
                    innerCircle.alpha = 1
                    indexLabel.isHidden = false
                    indexLabel.alpha = 1
                    innerCircle.snp.remakeConstraints { make in
                        make.edges.equalToSuperview()
                    }
                    innerCircle.layer.cornerRadius = kZZAPSelectionIndexBadgeViewRadius
                }
                
            } else {
                if shouldAnimateNextUpdate && !innerCircle.isHidden {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.innerCircle.alpha = 0
                        self.indexLabel.alpha = 0
                    }, completion: { _ in
                        self.innerCircle.isHidden = true
                        self.indexLabel.isHidden = true
                        self.indexLabel.text = nil
                    })
                } else {
                    innerCircle.isHidden = true
                    innerCircle.alpha = 0
                    indexLabel.isHidden = true
                    indexLabel.alpha = 0
                    indexLabel.text = nil
                }
            }
        }
        shouldAnimateNextUpdate = false
    }
    
    // MARK: - Event Handlers
    
    /// Handle tap gesture event and notify delegate
    @objc private func handleTap() {
        shouldAnimateNextUpdate = true
        delegate?.badgeViewDidTap(self)
    }
    
    /// Handle long press gesture event and notify delegate
    @objc private func handleLongPress() {
        shouldAnimateNextUpdate = true
        delegate?.badgeViewDidLongPress(self)
    }
}
