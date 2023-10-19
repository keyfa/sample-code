//
//  HorizontalPillsView.swift
//  Pineapple
//
//  Created by Caoife Davis on 16/03/2023.
//  Copyright © 2023 Pineapple Labs Limited. All rights reserved.
//

import Foundation

protocol HorizontalPillsViewDelagate: AnyObject {
    func didSelectItem(at row: Int)
}

final class HorizontalPillsView: UIView {

    weak var delegate: HorizontalPillsViewDelagate?

    private var stringItems = [String]()
    private var mutualStringItems = [String]()

    var isSmallCellSize: Bool = false
    var hasGradient: Bool = false

    var contentInset: UIEdgeInsets = .zero {
        didSet {
            collectionView.contentInset = contentInset
        }
    }

    var allowSelection: Bool = false {
        didSet {
            collectionView.allowsSelection = allowSelection
        }
    }

    var selectedIndex: Int? {
        set {

            guard let selectedIndex = newValue else {
                collectionView.deselectAllItems(animated: false)
                return
            }

            collectionView.selectItem(at: IndexPath(row: selectedIndex, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        }

        get {
            return collectionView.indexPathsForSelectedItems?.first?.row
        }
    }

    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        return flowLayout
    }()

    private lazy var collectionView: UICollectionView = {

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.allowsSelection = false
        collectionView.registerCell(PillCollectionViewCell.self)
        collectionView.isScrollEnabled = true
        collectionView.clipsToBounds = false
        collectionView.showsHorizontalScrollIndicator = false

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView

    }()

    override init(frame: CGRect) {
        super.init(frame: .zero)

        backgroundColor = .clear
        setupUI()
    }

    init(stringItems: [String]) {

        self.stringItems = stringItems
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard hasGradient else { return }
        addGradient()
    }

    private func setupUI() {

        clipsToBounds = true
        addSubview(collectionView)
        setUpConstraints()
    }

    private func setUpConstraints() {

        NSLayoutConstraint.activate([

            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    func setType(_ stringItems: [String], mutualStringItems: [String] = []) {

        self.stringItems = stringItems
        self.mutualStringItems = mutualStringItems

        self.stringItems.removeAll { mutualStringItems.contains($0) }
        self.stringItems = mutualStringItems + self.stringItems

        collectionView.reloadData()
    }

    func removeAll() {
        stringItems = []
        collectionView.reloadData()
    }
}

extension HorizontalPillsView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stringItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(PillCollectionViewCell.self, for: indexPath)

        let type = stringItems[indexPath.row]
        let isMutual = mutualStringItems.contains(type)

        if isSmallCellSize {

            cell.font = PAFont.Font12Bold
            cell.stackViewSpacing = CommonConstants.tiny
            cell.mutualIndicatorSize = CommonConstants.small
            cell.cellSize = PillCollectionViewCell.smallCellHeight
        }

        cell.setupUI(title: type, isMutual: isMutual)

        return cell
    }
}

extension HorizontalPillsView: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectItem(at: indexPath.row)
    }
}
