//
//  LabelWithLeadingImage.swift
//  Pineapple
//
//  Created by Caoife Davis on 19/03/2023.
//  Copyright © 2023 Pineapple Labs Limited. All rights reserved.
//

import Foundation

final class LabelWithLeadingImage: UIView {

    var letterSpacing: CGFloat = -0.48 {
        didSet {
            label.setTextWithLetterSpacing(string: text ?? "", letterSpacing: letterSpacing)
        }
    }

    var iconSize: CGFloat = CommonConstants.defaultSize {
        didSet {
            iconHeightContraint.constant = iconSize
            layoutIfNeeded()
        }
    }

    var iconImage: UIImage? {
        didSet {
            iconImageView.image = iconImage
        }
    }

    var text: String? {
        didSet {
            label.setTextWithLetterSpacing(string: text ?? "", letterSpacing: letterSpacing)
        }
    }

    var font: UIFont = PAFont.Font14Regular {
        didSet {
            label.font = font
        }
    }

    var spacing: CGFloat = 0.0 {
        didSet {
            stackView.spacing = spacing
        }
    }

    var textColor: UIColor = .black {
        didSet {
            label.textColor = textColor
        }
    }

    var horizontalInset: CGFloat = 0.0 {
        didSet {

            stackViewTrailingConstraint.constant = horizontalInset
            stackViewLeadingConstraint.constant = horizontalInset
            layoutIfNeeded()
        }
    }

    private lazy var iconHeightContraint: NSLayoutConstraint = {
        return iconImageView.heightAnchor.constraint(equalToConstant: iconSize)
    }()

    private lazy var stackViewTrailingConstraint: NSLayoutConstraint = {
        return stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
    }()

    private lazy var stackViewLeadingConstraint: NSLayoutConstraint = {
        return stackView.leadingAnchor.constraint(equalTo: leadingAnchor)
    }()

    private let stackView: UIStackView = {

        let stackView = UIStackView()

        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.distribution = .fill

        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var label: UILabel = {

        let label = UILabel()
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let iconImageView: UIImageView = {

        let imageView = UIImageView()

        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {

        addSubview(stackView)
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(label)

        setupConstraints()
    }

    private func setupConstraints() {

        NSLayoutConstraint.activate([

            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackViewLeadingConstraint,
            stackViewTrailingConstraint,

            iconHeightContraint,
            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor)
        ])
    }
}
