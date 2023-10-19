//
//  OpportunityFilterTableViewCell.swift
//  Pineapple
//
//  Created by Caoife Davis on 17/03/2023.
//  Copyright © 2023 Pineapple Labs Limited. All rights reserved.
//

import Foundation

protocol OpportunityFilterTableViewCellDelegate: AnyObject {
    func didTapMoreFilters()
    func didTapLocationsFilter()
}

final class OpportunityFilterTableViewCell: UITableViewCell {

    weak var delegate: OpportunityFilterTableViewCellDelegate?

    private let letterSpacing: CGFloat = -0.48
    private let smallLetterSpacing: CGFloat = -0.36
    private let filterIconSize: CGFloat = 13.0
    private let locationFilterTopDistance: CGFloat = 6.0
    private let editFilterSpacing: CGFloat = 2.0
    private let addedTapScace: CGFloat = CommonConstants.tiny
    private let appliedFilterViewHeight: CGFloat = 20.0

    private let titleText = "filters"
    private let moreFiltersText = "More Filters"
    private let editFilterText = "Edit Filters"
    private let forHighschoolersText = "high school"

    private lazy var titleLabel: UILabel = {

        let label = UILabel()

        label.font = PAFont.Font18Bold
        label.setTextWithLetterSpacing(string: titleText, letterSpacing: letterSpacing)

        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var appliedFiltersView: AppliedOpportunitiesFiltersView = {

        let view = AppliedOpportunitiesFiltersView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let editFilterTapView: UIView = {

        let view = UIView()
        view.backgroundColor = .clear

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var editFilterLabel: LabelWithLeadingImage = {

        let label = LabelWithLeadingImage()

        label.font = PAFont.Font13Heavy
        label.textColor = PAColor.lightBlue
        label.text = moreFiltersText
        label.letterSpacing = letterSpacing
        label.iconImage = #imageLiteral(resourceName: "filterIconBlue")
        label.iconSize = filterIconSize
        label.spacing = editFilterSpacing

        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        setupGestureRecognizers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupGestureRecognizers() {

        let editFiltersTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapEditFiltersLabel))
        editFilterTapView.addGestureRecognizer(editFiltersTapGesture)

        let appliedFiltersTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapEditFiltersLabel))
        appliedFiltersView.addGestureRecognizer(appliedFiltersTapGesture)
    }

    private func setupLayout() {

        selectionStyle = .none
        backgroundColor = .white

        contentView.addSubview(titleLabel)
        contentView.addSubview(editFilterLabel)
        contentView.addSubview(appliedFiltersView)
        contentView.addSubview(editFilterTapView)

        setupConstraints()
    }

    func setupUI(locationIds: [String], isHighSchoolFilterSelected: Bool = false, industriesIds: [String]) {

        appliedFiltersView.setupUI(locationIds: locationIds,
                                   isOpenToHighschoolers: isHighSchoolFilterSelected,
                                   industryIds: industriesIds)

        guard locationIds.isEmpty && !isHighSchoolFilterSelected && industriesIds.isEmpty else {
            editFilterLabel.text = editFilterText
            return
        }

        editFilterLabel.text = moreFiltersText
    }

    private func setupConstraints() {

        NSLayoutConstraint.activate([

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CommonConstants.defaultSize),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CommonConstants.defaultSize),
            titleLabel.trailingAnchor.constraint(equalTo: editFilterLabel.leadingAnchor, constant: -CommonConstants.small),

            editFilterLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            editFilterLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CommonConstants.defaultSize),

            appliedFiltersView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: locationFilterTopDistance),
            appliedFiltersView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            appliedFiltersView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CommonConstants.defaultSize),
            appliedFiltersView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CommonConstants.defaultSize),
            appliedFiltersView.heightAnchor.constraint(equalToConstant: appliedFilterViewHeight),

            editFilterTapView.topAnchor.constraint(equalTo: editFilterLabel.topAnchor, constant: -addedTapScace),
            editFilterTapView.bottomAnchor.constraint(equalTo: editFilterLabel.bottomAnchor, constant: addedTapScace),
            editFilterTapView.leadingAnchor.constraint(equalTo: editFilterLabel.leadingAnchor, constant: -addedTapScace),
            editFilterTapView.trailingAnchor.constraint(equalTo: editFilterLabel.trailingAnchor, constant: addedTapScace)

        ])
    }

    @objc private func didTapEditFiltersLabel() {
        delegate?.didTapMoreFilters()
    }

    @objc private func didTapLocationsLabel() {
        delegate?.didTapLocationsFilter()
    }

    @objc private func didTapHighschoolFilterLabel() {
        delegate?.didTapMoreFilters()
    }
}
