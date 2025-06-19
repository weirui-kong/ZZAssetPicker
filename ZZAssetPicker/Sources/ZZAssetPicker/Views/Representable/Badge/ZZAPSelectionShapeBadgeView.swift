//
//  ZZAPSelectionShapeBadgeView.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/20/25.
//

import UIKit
import SnapKit

/// Radius for shape badge view
public let kZZAPSelectionShapeBadgeViewRadius: CGFloat = 8.0

// MARK: - Shape Badge View

@objcMembers
public class ZZAPSelectionShapeBadgeView: UIView, ZZAPSelectionBadgeViewProtocol {
    
    // MARK: Public Properties

    /// Delegate for tap/long press events
    public weak var delegate: ZZAPSelectionBadgeViewDelegate?

    /// Current selection mode (none/single/multiple)
    public var selectionMode: ZZAPSelectionMode = .none {
        didSet { refreshAppearance() }
    }

    /// Selection index, used to determine visibility
    public var index: Int = 0 {
        didSet { refreshAppearance() }
    }

    /// Image shown inside the badge (overrides symbolName)
    public var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }

    // MARK: Internal Properties

    /// Image view shown inside the circle
    internal let imageView = UIImageView()

    /// Circular background view
    internal let backgroundCircle = UIView()

    /// Backing storage for `symbolName`
    internal var _symbolName: String?

    // MARK: Initialization

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGestures()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UI Setup

    private func setupUI() {
        addSubview(backgroundCircle)
        backgroundCircle.backgroundColor = UIColor.white
        backgroundCircle.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        backgroundCircle.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .black
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(2)
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        backgroundCircle.layer.cornerRadius = bounds.width / 2
    }

    // MARK: Gesture Setup

    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        addGestureRecognizer(longPress)
    }

    // MARK: Appearance

    /// Updates visibility based on selection mode and index
    private func refreshAppearance() {
        switch selectionMode {
        case .none:
            isHidden = true
        default:
            isHidden = false
            backgroundCircle.isHidden = index == 0
            imageView.isHidden = index == 0
        }
    }

    // MARK: Gesture Handlers

    @objc private func handleTap() {
        delegate?.badgeViewDidTap(self)
    }

    @objc private func handleLongPress() {
        delegate?.badgeViewDidLongPress(self)
    }
}

// MARK: - SF Symbol Support

@available(iOS 13.0, *)
extension ZZAPSelectionShapeBadgeView {

    /// SF Symbol name (only available in iOS 13+)
    /// When set, overrides the image with a system image.
    public var symbolName: String? {
        get { _symbolName }
        set {
            _symbolName = newValue
            imageView.image = newValue.flatMap { UIImage(systemName: $0) }
        }
    }
}
