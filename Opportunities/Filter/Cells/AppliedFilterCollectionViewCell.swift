//
//  AppliedFilterCollectionViewCell.swift
//  Pineapple
//
//  Created by Caoife Davis on 28/03/2023.
//  Copyright © 2023 Pineapple Labs Limited. All rights reserved.
//

import Foundation

final class AppliedFilterCollectionViewCell: UICollectionViewCell {

    private let letterSpacing: CGFloat = -0.48

    private lazy var filterLabel: LabelWithLeadingImage = {

        let label = LabelWithLeadingImage()

        label.font = PAFont.Font16Bold
        label.textColor = PAColor.descriptionGrey
        label.letterSpacing = letterSpacing
        label.iconSize = CommonConstants.defaultSize
        label.spacing = CommonConstants.tiny
        label.setContentHuggingPriority(.required, for: .horizontal)

        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        contentView.addSubview(filterLabel)
        setupConstraints()
    }

    func setupUI(title: String? = nil, icon: UIImage?) {
        filterLabel.text = title
        filterLabel.iconImage = icon
    }

    private func setupConstraints() {

        NSLayoutConstraint.activate([

            filterLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            filterLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            filterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            filterLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}
