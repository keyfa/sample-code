//
//  AppliedOpportunitiesFiltersView.swift
//  Pineapple
//
//  Created by Caoife Davis on 28/03/2023.
//  Copyright © 2023 Pineapple Labs Limited. All rights reserved.
//

import Foundation

final class AppliedOpportunitiesFiltersView: UIView {

    private var types = [OpportunityFilterSections: [String]]()
    private var orderedKeys = [OpportunityFilterSections]()

    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        return flowLayout
    }()

    private lazy var collectionView: UICollectionView = {

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.allowsSelection = false
        collectionView.registerCell(AppliedFilterCollectionViewCell.self)
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

    func setupUI(locationIds: [String], isOpenToHighschoolers: Bool, industryIds: [String]) {

        types.removeAll()
        types[.location] = locationIds

        if isOpenToHighschoolers {
            types[.openToHighSchoolers] = []
        }

        if !industryIds.isEmpty {
            types[.industry] = industryIds
        }

        orderedKeys = types.keys.sorted(by: { $0.rawValue < $1.rawValue })

        collectionView.reloadData()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: CommonConstants.defaultSize)
        ])
    }

    func removeAll() {
        types.removeAll()
        collectionView.reloadData()
    }
}

extension AppliedOpportunitiesFiltersView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return types.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(AppliedFilterCollectionViewCell.self, for: indexPath)

        let rowType = orderedKeys[indexPath.row]

        let typeIds = types[rowType] ?? []
        let title = rowType.getAppliedFilterTitle(for: typeIds)?.lowercased()
        cell.setupUI(title: title, icon: rowType.iconImage)

        return cell
    }
}
