//
//  OpportunityEmptyStateTableViewCell.swift
//  Pineapple
//
//  Created by Caoife Davis on 18/03/2023.
//  Copyright © 2023 Pineapple Labs Limited. All rights reserved.
//

import Foundation

protocol OpportunityEmptyStateDelegate: AnyObject {
    func didTapGradientButton()
}

final class OpportunityEmptyStateTableViewCell: UITableViewCell {

    weak var delegate: OpportunityEmptyStateDelegate?

    private let gradientButtonHeight: CGFloat = 47.0
    private let titleSpacing: CGFloat = -0.77
    private let gradientButtonSpacing: CGFloat = -0.36

    private let containerView: UIView = {

        let view = UIView()
        view.backgroundColor = PAColor.LightestGrey
        view.addCornerRadius(cornerRadius: CommonConstants.massive)

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleLabel: UILabel = {

        let label = UILabel()
        label.font = PAFont.Font21Bold
        label.textAlignment = .center
        label.numberOfLines = 0

        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var gradientButton: PineappleGradientButton = {

        let button = PineappleGradientButton(wrapContent: false)
        button.addTarget(self, action: #selector(didTapGradientButton), for: .touchUpInside)
        button.hasGradientText = false
        button.font = PAFont.Font15Heavy
        button.letterSpacing = gradientButtonSpacing

        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI(_ state: OpportunityEmptyState) {
        titleLabel.setTextWithLetterSpacing(string: state.title, letterSpacing: titleSpacing)
        gradientButton.title = state.buttonTitle
    }

    private func setupLayout() {

        backgroundColor = .white
        selectionStyle = .none

        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(gradientButton)

        setupConstraints()
    }

    private func setupConstraints() {

        NSLayoutConstraint.activate([

            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CommonConstants.small),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CommonConstants.defaultSize),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CommonConstants.defaultSize),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: CommonConstants.huge),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: CommonConstants.defaultSize),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -CommonConstants.defaultSize),

            gradientButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: CommonConstants.defaultSize),
            gradientButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -CommonConstants.huge),
            gradientButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: CommonConstants.large),
            gradientButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -CommonConstants.large),
            gradientButton.heightAnchor.constraint(equalToConstant: gradientButtonHeight)
        ])
    }

    @objc private func didTapGradientButton() {
        delegate?.didTapGradientButton()
    }
}
