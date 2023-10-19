//
//  OpportunityListingTableViewCell.swift
//  Pineapple
//
//  Created by Caoife Davis on 13/03/2023.
//  Copyright © 2023 Pineapple Labs Limited. All rights reserved.
//

import Foundation
import Shimmer

final class OpportunityListingTableViewCell: UITableViewCell {

    var showBlurrBackground: Bool = false {
        didSet {
            showBlurrBackground ? opportunityView.addBlurBackground() : opportunityView.removeBlurBackground()
        }
    }

    private(set) lazy var opportunityView: OpportunityListingView = {

        let view = OpportunityListingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        opportunityView.prepareForReuse()
    }

    func setupUI(_ opportunity: Opportunity?, isFirstElement: Bool = false, isLastElement: Bool = false) {
        opportunityView.setupUI(opportunity, isFirstElement: isFirstElement, isLastElement: isLastElement)
    }

    private func setupLayout() {

        selectionStyle = .none
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
