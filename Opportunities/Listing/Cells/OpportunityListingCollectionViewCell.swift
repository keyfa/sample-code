//
//  OpportunityListingCollectionViewCell.swift
//  Pineapple
//
//  Created by Caoife Davis on 14/04/2023.
//  Copyright © 2023 Pineapple Labs Limited. All rights reserved.
//

import Foundation

final class OpportunityListingCollectionViewCell: UICollectionViewCell {

    private lazy var opportunityView: OpportunityListingView = {

        let view = OpportunityListingView(horizontalSpacing: CommonConstants.tiny)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        opportunityView.prepareForReuse()
    }

    func setupUI(_ opportunity: Opportunity?) {
        opportunityView.setupUI(opportunity)
    }

    private func setupLayout() {
        contentView.addSubview(opportunityView)
        setupConstraints()
    }

    private func setupConstraints() {

        NSLayoutConstraint.activate([

            opportunityView.topAnchor.constraint(equalTo: contentView.topAnchor),
            opportunityView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            opportunityView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            opportunityView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}
