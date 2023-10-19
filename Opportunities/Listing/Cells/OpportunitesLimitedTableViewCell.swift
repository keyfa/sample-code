//
//  OpportunitesLimitedTableViewCell.swift
//  Pineapple
//
//  Created by Caoife Davis on 15/03/2023.
//  Copyright © 2023 Pineapple Labs Limited. All rights reserved.
//

import Foundation

protocol OpportunitesLimitedTableViewCellDelegate: AnyObject {
    func didTapReferralButton()
    func didTapShowMoreOpportunities()
}

final class OpportunitesLimitedTableViewCell: UITableViewCell {

    weak var delegate: OpportunitesLimitedTableViewCellDelegate?

    private let letterSpacing: CGFloat = -0.39
    private let accessedTitleLetterSpacing: CGFloat = -0.36
    private let titleLetterSpacing: CGFloat = -0.77
    private let descriptionLetterSpacing: CGFloat = -0.48
    private let imageViewSize: CGFloat = 29.0
    private let conatinerViewBottomDistance: CGFloat = 83.0
    private let gradientButtonHeight: CGFloat = 47.0
    private let iconSize: CGFloat = 27.0
    private let animationDuration: CGFloat = 0.33
    private let backgroundImageViewHeight: CGFloat = 368.0

    private let dropShadowOpacity: Float = 0.2
    private let dropShadowRadius: CGFloat = 18.0
    private let dropShadowOffset: CGSize = CGSize(width: 0, height: 4)

    private let opportunitiesLimitedTitle: String = "invite a friend to unlock more opportunities"
    private let opportunitiesLimitedDescription: String = "bring a friend to Pineapple to access over 1,000 more opportunities."
    private let opportunitiesLimitedButtonText: String = "invite a friend"
    private let opportunitiesAccessedTitle: String = "here we go!"
    private let opportunitiesAccessedDescription: String = "you’re ready to see all opportunites"
    private let opportunitiesAccessedButtonText: String = "let’s dive in"

    private let backgroundImageView: UIImageView = {

        let view = UIImageView()
        view.image = #imageLiteral(resourceName: "opportunitiesLimitedBlurImage")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let hiddenCellsImageView: UIImageView = {

        let view = UIImageView()
        view.image = #imageLiteral(resourceName: "opportunitiesLimitedBlurImage")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var containerView: UIView = {

        let view = UIView()
        view.backgroundColor = .white
        view.addDropShadow(withRadius: dropShadowRadius,
                           offset: dropShadowOffset,
                           opacity: dropShadowOpacity)
        view.addCornerRadius(cornerRadius: CommonConstants.massive)

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {

        let label = UILabel()
        label.font = PAFont.Font24Bold
        label.textAlignment = .center
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)

        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var descriptionLabel: UILabel = {

        let label = UILabel()
        label.font = PAFont.Font16Semibold
        label.textAlignment = .center
        label.textColor = PAColor.descriptionGrey
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)

        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var gradientButton: PineappleGradientButton = {

        let button = PineappleGradientButton(wrapContent: false)
        button.addTarget(self, action: #selector(didTapGradientButton), for: .touchUpInside)
        button.hasGradientText = false
        button.font = PAFont.Font15Heavy

        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var stackView: UIStackView = {

        let stackView = UIStackView()

        stackView.distribution = .fillProportionally
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = CommonConstants.defaultSize

        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let iconImageView: UIImageView = {

        let view = UIImageView()
        view.image = #imageLiteral(resourceName: "iconProfileComplete")
        view.isHidden = true
        view.alpha = 0
        view.contentMode = .scaleAspectFit

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {

        titleLabel.setTextWithLetterSpacing(string: opportunitiesLimitedTitle, letterSpacing: titleLetterSpacing)
        descriptionLabel.setTextWithLetterSpacing(string: opportunitiesLimitedDescription, letterSpacing: descriptionLetterSpacing)
        gradientButton.title = opportunitiesLimitedButtonText

        setupLayout()
    }

    private func setupLayout() {

        clipsToBounds = false
        selectionStyle = .none
        backgroundColor = PAColor.tableViewLightGrey

        addSubview(hiddenCellsImageView)
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(containerView)
        containerView.addSubview(stackView)
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        containerView.addSubview(gradientButton)

        setupConstraints()
    }

    private func setupConstraints() {

        NSLayoutConstraint.activate([

            hiddenCellsImageView.topAnchor.constraint(equalTo: backgroundImageView.bottomAnchor),
            hiddenCellsImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            hiddenCellsImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            hiddenCellsImageView.heightAnchor.constraint(equalToConstant: backgroundImageViewHeight),

            backgroundImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundImageView.heightAnchor.constraint(equalToConstant: backgroundImageViewHeight),

            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CommonConstants.tiny),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CommonConstants.small),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CommonConstants.small),

            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: CommonConstants.massive),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: CommonConstants.large),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -CommonConstants.large),

            gradientButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: CommonConstants.massive),

            gradientButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -CommonConstants.massive),
            gradientButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: CommonConstants.large),
            gradientButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -CommonConstants.large),
            gradientButton.heightAnchor.constraint(equalToConstant: gradientButtonHeight),

            iconImageView.heightAnchor.constraint(equalToConstant: iconSize)
        ])
    }

    @objc private func didTapGradientButton() {

        HapticController.emit(style: .medium)

        if UserController.shared.activeUser?.canAccessAllOpportunities == true {
            hideAccessLimitedUI()
            delegate?.didTapShowMoreOpportunities()
        } else {

            SegmentUtil.trackEvent()?.opportunitiesReferralButtonTapped()
            delegate?.didTapReferralButton()
        }
    }

    private func showUserHasAccess() {

        titleLabel.setTextWithLetterSpacing(string: opportunitiesAccessedTitle, letterSpacing: accessedTitleLetterSpacing)
        descriptionLabel.setTextWithLetterSpacing(string: opportunitiesAccessedDescription, letterSpacing: letterSpacing)
        gradientButton.title = opportunitiesAccessedButtonText
        iconImageView.isHidden = false
        iconImageView.alpha = 1
    }

    private func hideAccessLimitedUI() {

        gradientButton.isEnabled = false

        UIView.animate(withDuration: animationDuration) { [weak self] in
            self?.containerView.alpha = 0
        }
    }
}

extension OpportunitesLimitedTableViewCell: OpportunitiesLimitedDelegate {

    func canAccessOpportunities() {

        UIView.animate(withDuration: animationDuration) { [weak self] in
            self?.showUserHasAccess()
        }
    }
}
