//
//  ZZAPCollectionPresenterView.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 7/19/25.
//

import UIKit
import Photos
import SnapKit

@objcMembers
public class ZZAPCollectionPresenterView: UIView {
    public var presenter: ZZAPCollectionPresenter? {
        didSet {
            oldValue?.removeCollectionDelegate?(self)
            presenter?.addCollectionDelegate?(self)
            reloadData()
        }
    }
    private let scrollView = UIScrollView()
    private var stackView: UIStackView = UIStackView()
    private var capsuleButtons: [UIButton] = []
    public var onSelect: ((PHAssetCollection) -> Void)?
    public var capsuleHeight: CGFloat = 32
    public var capsuleSpacing: CGFloat = 8
    public var verticalPadding: CGFloat = 6
    private var assetCountCache: [String: Int] = [:]
    private var didAnimateAppear = false
    private var lastSelectedId: String?
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    private func setupView() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(verticalPadding)
            make.bottom.equalToSuperview().offset(-verticalPadding)
            make.left.right.equalToSuperview()
        }
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = capsuleSpacing
        scrollView.addSubview(stackView)
        scrollView.contentInset = UIEdgeInsets(top: 0, left: capsuleSpacing, bottom: 0, right: capsuleSpacing)
        scrollView.clipsToBounds = false
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
        self.snp.makeConstraints { make in
            make.height.equalTo(0)
        }
    }
    private func reloadData() {
        capsuleButtons.forEach { $0.removeFromSuperview() }
        capsuleButtons.removeAll()
        guard let presenter = presenter, presenter.collections.count > 0 else {
            self.snp.updateConstraints { make in
                make.height.equalTo(0)
            }
            didAnimateAppear = false
            layoutIfNeeded()
            return
        }
        var counts: [String: Int] = [:]
        for collection in presenter.collections {
            let cacheKey = collection.localIdentifier
            let count = PHAsset.fetchAssets(in: collection, options: nil).count
            counts[cacheKey] = count
            assetCountCache[cacheKey] = count
        }
        self.snp.updateConstraints { make in
            make.height.equalTo(capsuleHeight + verticalPadding * 2)
        }
        let currentId = presenter.currentCollection?.localIdentifier
        for (idx, collection) in presenter.collections.enumerated() {
            let button = UIButton(type: .system)
            let baseTitle = collection.localizedTitle ?? "Album"
            let cacheKey = collection.localIdentifier
            let count = counts[cacheKey] ?? 0
            button.setTitle("\(baseTitle) (\(count))", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            button.setTitleColor(.black, for: .normal)
            button.backgroundColor = .clear
            button.layer.cornerRadius = capsuleHeight / 2
            button.layer.masksToBounds = true
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.lightGray.cgColor
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            button.snp.makeConstraints { make in
                make.height.equalTo(capsuleHeight)
            }
            if currentId == collection.localIdentifier {
                button.backgroundColor = .zzapThemeColor.withAlphaComponent(0.15)
                button.setTitleColor(.zzapThemeColor, for: .normal)
                button.layer.borderColor = UIColor.zzapThemeColor.cgColor
                if let last = lastSelectedId, last != currentId {
                    UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
                        button.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
                    }, completion: { _ in
                        UIView.animate(withDuration: 0.15) {
                            button.transform = .identity
                        }
                    })
                }
            }
            button.addTarget(self, action: #selector(capsuleTapped(_:)), for: .touchUpInside)
            button.tag = capsuleButtons.count
            stackView.addArrangedSubview(button)
            capsuleButtons.append(button)
        }
        
        layoutIfNeeded()
        if !didAnimateAppear {
            for (i, button) in capsuleButtons.enumerated() {
                button.alpha = 0
                button.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                UIView.animate(withDuration: 0.5, delay: 0.05 * Double(i), options: [.curveEaseOut], animations: {
                    button.alpha = 1
                    button.transform = .identity
                }, completion: nil)
            }
            didAnimateAppear = true
        }
        lastSelectedId = currentId
    }

    @objc private func capsuleTapped(_ sender: UIButton) {
        guard let presenter = presenter else { return }
        let index = sender.tag
        guard index < presenter.collections.count else { return }
        let collection = presenter.collections[index]
        if (collection != presenter.currentCollection) {
            presenter.updateCollection(collection)
            onSelect?(collection)
        }
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            sender.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
        }, completion: { _ in
            UIView.animate(withDuration: 0.15) {
                sender.transform = .identity
            }
        })
    }
}


extension ZZAPCollectionPresenterView: ZZAPCollectionPresenterDelegate {
    public func collectionPresenter(_ presenter: ZZAPCollectionPresenter, didUpdateCollections collections: [PHAssetCollection]) {
        reloadData()
    }

    public func collectionPresenter(_ presenter: ZZAPCollectionPresenter, didUpdateCurrentCollection collection: PHAssetCollection?) {
        reloadData()
    }
} 
