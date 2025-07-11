//
//  ZZAPSelectionIndicatorBar.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/19/25.
//

import UIKit
import SnapKit

@objcMembers
public class ZZAPSelectionIndicatorBar: UIView, ZZAPSelectionIndicator {

    public weak var delegate: ZZAPSelectableDelegate?
    public var selectionController: ZZAPSelectable? {
        willSet {
            selectionController?.removeSelectableDelegate?(self)
        }
        didSet {
            selectionController?.addSelectableDelegate?(self)
        }
    }
    
    public var isExpanded: Bool  {
        selectionController?.selectedAssets.count ?? 0 > 0
    }

    private let blurView: UIVisualEffectView
    private let contentView: UIView
    private let collectionView: UICollectionView
    private let buttonStackView: UIStackView
    private let composeButton: UIButton
    private let nextButton: UIButton

    public override init(frame: CGRect) {
        if ZZAPDeviceSupport.supportsBlurEffect {
            let blurEffect: UIBlurEffect
            if #available(iOS 13.0, *) {
                blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
            } else {
                blurEffect = UIBlurEffect(style: .regular)
            }
            blurView = UIVisualEffectView(effect: blurEffect)
        } else {
            let fallbackView = UIVisualEffectView(effect: nil)
            fallbackView.backgroundColor = UIColor.black.withAlphaComponent(0.87)
            blurView = fallbackView
        }
        
        contentView = UIView()

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = kZZAPSelectionShapeBadgeViewRadius * 0.5
        layout.minimumInteritemSpacing = kZZAPSelectionShapeBadgeViewRadius * 1.5
        layout.itemSize = CGSize(width: 72, height: 72)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: kZZAPSelectionShapeBadgeViewRadius, left: kZZAPSelectionShapeBadgeViewRadius, bottom: kZZAPSelectionShapeBadgeViewRadius, right: kZZAPSelectionShapeBadgeViewRadius)

        composeButton = UIButton(type: .system)
        composeButton.setTitle(ZZAPLocalized("zzap_selection_indicator_btn_title_oneclip"), for: .normal)
        composeButton.setTitleColor(.white, for: .normal)
        composeButton.backgroundColor = .zzapThemeColor
        composeButton.titleLabel?.font = .boldSystemFont(ofSize: 14)
        composeButton.layer.cornerRadius = 8
        composeButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
        

        nextButton = UIButton(type: .system)
        nextButton.setTitle(ZZAPLocalized("zzap_selection_indicator_btn_title_next"), for: .normal)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.backgroundColor = .zzapThemeColor
        nextButton.titleLabel?.font = .boldSystemFont(ofSize: 14)
        nextButton.layer.cornerRadius = 8
        nextButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)

        buttonStackView = UIStackView(arrangedSubviews: [nextButton, composeButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 8
        buttonStackView.alignment = .center
        buttonStackView.distribution = .equalSpacing

        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var intrinsicContentSize: CGSize {
        let hasItems = (selectionController?.selectedAssets.count ?? 0) > 0
        
        var totalHeight: CGFloat = superview?.safeAreaInsets.bottom ?? 0
        
        totalHeight += 12
        
        if hasItems && isExpanded {
            totalHeight += 96
            totalHeight += 8
        }
        
        totalHeight += 32
        totalHeight += 8
        
        return CGSize(width: UIView.noIntrinsicMetric, height: totalHeight)
    }

    private func setupUI() {
        layer.masksToBounds = true
        layer.cornerRadius = 12

        addSubview(blurView)
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }

        contentView.addSubview(collectionView)
        contentView.addSubview(buttonStackView)

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            ZZAPIndicatorAssetCell.self,
            forCellWithReuseIdentifier: ZZAPIndicatorAssetCell.reuseIdentifier
        )

        collectionView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview().inset(12)
            make.height.equalTo(isExpanded ? 96 : 0)
        }

        buttonStackView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(12)
            make.height.equalTo(32)
            make.bottom.equalToSuperview().inset(8)
        }

        composeButton.addTarget(self, action: #selector(didTapCompose), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        updateButtonStyleIfNeeded()
    }
    
    private func updateExpansionState(animated: Bool) {
        let targetHeight: CGFloat = isExpanded ? 96 : 0

        if animated {
            self.collectionView.snp.updateConstraints { make in
                make.height.equalTo(targetHeight)
            }
            self.invalidateIntrinsicContentSize()
            
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.5,
                options: [.curveEaseInOut],
                animations: {
                    self.superview?.layoutIfNeeded()
                },
                completion: nil
            )
        } else {
            collectionView.snp.updateConstraints { make in
                make.height.equalTo(targetHeight)
            }
            invalidateIntrinsicContentSize()
        }
    }


    public func reloadSelectionDisplay() {
        collectionView.reloadData()
        updateExpansionState(animated: false)
    }

    @objc private func didTapNext() {
    }

    @objc private func didTapCompose() {
    }
}

extension ZZAPSelectionIndicatorBar {
    func updateButtonStyleIfNeeded() {
        self.nextButton.isEnabled = !(selectionController?.selectedAssets.isEmpty ?? true)
        self.nextButton.alpha = (selectionController?.selectedAssets.isEmpty ?? true) ? 0.6 : 1
        self.composeButton.isEnabled = !(selectionController?.selectedAssets.isEmpty ?? true)
        self.composeButton.alpha = (selectionController?.selectedAssets.isEmpty ?? true) ? 0.6 : 1
    }
}
extension ZZAPSelectionIndicatorBar: ZZAPSelectableDelegate {
    public func selectable(_ selectable: any ZZAPSelectable, from sender: AnyObject?, didChangeSelection selectedAssets: [Int : any ZZAPAsset]) {
        updateButtonStyleIfNeeded()
        collectionView.reloadData()
        updateExpansionState(animated: true)
    }
}

extension ZZAPSelectionIndicatorBar: ZZAPAssetCellBaseDelegate {
    public func assetCell(_ cell: ZZAPAssetCellBase, didTapBadgeFor asset: (any ZZAPAsset)?) {
        guard let asset = asset else { return }
        guard let index = selectionController?.index?(self, for: asset), index != NSNotFound else { return }
        selectionController?.removeAsset?(self, at: index)
    }
}

extension ZZAPSelectionIndicatorBar: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectionController?.selectedAssets.count ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZZAPIndicatorAssetCell.reuseIdentifier, for: indexPath) as? ZZAPIndicatorAssetCell,
            let asset = selectionController?.orderedSelectedAssets?[indexPath.item]
        else {
            return UICollectionViewCell()
        }
        cell.delegate = self
        cell.selectionMode = selectionController?.selectionMode ?? .none
        cell.selectedIndex = indexPath.item + 1
        cell.clearWhenPreparingForReuse = false
        cell.configure(with: asset)
        if let asset = asset as? ZZAPPHAsset {
            asset.cacheImage = true
        }
        
        return cell
    }
}
