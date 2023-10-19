//
//  HeaderCollectionReuseableView.swift
//  Pineapple
//
//  Created by Caoife Davis on 17/03/2023.
//  Copyright © 2023 Pineapple Labs Limited. All rights reserved.
//

import Foundation

final class HeaderCollectionReuseableView: UICollectionReusableView {

    static let height: CGFloat = 58.0
    private let letterSpacing: CGFloat = -0.48

    private lazy var titleLabel: UILabel = {

        let label = UILabel()

        label.font = PAFont.Font18Bold
        label.numberOfLines = 1

        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    private func setupLayout() {
        addSubview(titleLabel)
        setupConstraints()
    }

    func setupUI(title: String) {
        titleLabel.setTextWithLetterSpacing(string: title,
                                            letterSpacing: letterSpacing)
    }

    private func setupConstraints() {

        NSLayoutConstraint.activate([

            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: CommonConstants.large),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
