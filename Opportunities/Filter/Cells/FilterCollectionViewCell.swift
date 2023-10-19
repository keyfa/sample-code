//
//  FilterCollectionViewCell.swift
//  Pineapple
//
//  Created by Caoife Davis on 17/03/2023.
//  Copyright © 2023 Pineapple Labs Limited. All rights reserved.
//

import Foundation

final class FilterCollectionViewCell: UICollectionViewCell {

    private let cellHeight: CGFloat = 57.0
    private let letterSpacing: CGFloat = -0.36
    private let checkBoxSize: CGFloat = CommonConstants.defaultSize
    private let chevronWidth: CGFloat = CommonConstants.defaultSize
    private let chevronHeight: CGFloat = CommonConstants.defaultSize

    var horizontalSpacing: CGFloat = CommonConstants.large {
        didSet {
            viewWidthConstraint.constant = UIScreen.main.bounds.width - (horizontalSpacing * 2)
            layoutIfNeeded()
        }
    }

    var isCheckBoxHidden: Bool = true {
        didSet {
            checkBox.isHidden = isCheckBoxHidden
        }
    }

    var isChevronHidden: Bool = false {
        didSet {
            rightChevronImageView.isHidden = isChevronHidden
        }
    }

    private lazy var checkBox: Checkbox = {

        let view = Checkbox()

        view.checkedImage = #imageLiteral(resourceName: "iconBlueChecklist")
        view.layer.borderWidth = 1
        view.layer.borderColor = PAColor.borderLightGrey.cgColor
        view.addCornerRadius(cornerRadius: checkBoxSize/2)
        view.isUserInteractionEnabled = false
        view.isHidden = true

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {

        let label = UILabel()
        label.font = PAFont.Font16Bold
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let rightChevronImageView: UIImageView = {

        let imageView = UIImageView()

        imageView.image = #imageLiteral(resourceName: "chevronRightLightGrey")
        imageView.contentMode = .scaleAspectFit

        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let stackView: UIStackView = {

        let stackView = UIStackView()

        stackView.distribution = .fillProportionally
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = CommonConstants.small

        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var viewWidthConstraint: NSLayoutConstraint = {
        return contentView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
    }()

    override var isSelected: Bool {
        didSet {

            super.isSelected = isSelected
            checkBox.isChecked = isSelected
            checkBox.layer.borderWidth = isSelected ? 0 : 1
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.addCornerRadius(cornerRadius: CommonConstants.large)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        titleLabel.text = nil
        checkBox.isChecked = false
    }

    private func setupLayout() {

        backgroundColor = .clear

        contentView.backgroundColor = .white
        contentView.clipsToBounds = true
        contentView.layer.borderColor = PAColor.borderLightGrey.cgColor
        contentView.layer.borderWidth = 1.0

        contentView.addSubview(stackView)
        stackView.addArrangedSubview(checkBox)
        stackView.addArrangedSubview(titleLabel)
        contentView.addSubview(rightChevronImageView)

        setupConstraints()
    }

    func setupUI(title: String) {
        titleLabel.textColor = .black
        titleLabel.setTextWithLetterSpacing(string: title, letterSpacing: letterSpacing)
    }

    func setupUI(placeholder: String) {
        titleLabel.textColor = PAColor.placeholderTextGrey
        titleLabel.setTextWithLetterSpacing(string: placeholder, letterSpacing: letterSpacing)
    }

    private func setupConstraints() {

        NSLayoutConstraint.activate([

            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CommonConstants.defaultSize),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CommonConstants.defaultSize),
            stackView.heightAnchor.constraint(equalToConstant: cellHeight),

            checkBox.widthAnchor.constraint(equalToConstant: checkBoxSize),
            checkBox.heightAnchor.constraint(equalToConstant: checkBoxSize),

            rightChevronImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rightChevronImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CommonConstants.defaultSize),
            rightChevronImageView.heightAnchor.constraint(equalToConstant: chevronWidth),
            rightChevronImageView.widthAnchor.constraint(equalToConstant: chevronHeight),

            viewWidthConstraint
        ])
    }
}
