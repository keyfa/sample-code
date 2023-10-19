//
//  PineappleGradientButton.swift
//  Pineapple
//
//  Created by Caoife Davis on 15/12/2022.
//  Copyright © 2022 Pineapple Labs Limited. All rights reserved.
//

import Foundation

class PineappleGradientButton: UIControl {

    var didSetupConstraints: Bool = false
    private let highlightedOpacity: CGFloat = 0.6

    var selectedTitle: String?
    var selectedIcon: UIImage?

    override var isHighlighted: Bool {
        didSet {

            guard isEnabled else {
                alpha = highlightedOpacity
                return
            }

            alpha = isHighlighted ? highlightedOpacity : 1.0
        }
    }

    override var isEnabled: Bool {
        didSet {
            isHighlighted = !isEnabled
        }
    }

    override var isSelected: Bool {

        didSet {

            super.isSelected = isSelected

            let currentTitle = isSelected ? selectedTitle : title
            let currentImage = isSelected ? selectedIcon : icon

            setTitle(currentTitle)
            setImage(currentImage)
        }
    }

    var hasGradientText: Bool = true {
        didSet {
            backgroundImageView.image = hasGradientText ? nil : gradientImage
        }
    }

    var font: UIFont = PAFont.Font18Medium {
        didSet {
            maskingTitleLabel.font = font
        }
    }

    var title: String? {
        didSet {
            setTitle(title)
        }
    }

    var icon: UIImage? {
        didSet {
            setImage(icon)
        }
    }

    var titleColour: UIColor = .black {
        didSet {
            textContainerImageView.backgroundColor = titleColour
            maskingTitleLabel.textColor = titleColour
        }
    }

    var isHiddenFromView: Bool = false {
        didSet {

            isHidden = isHiddenFromView
            zeroWidthConstraint.isActive = isHiddenFromView
            zeroHeightConstraint.isActive = isHiddenFromView
            layoutIfNeeded()
        }
    }

    var letterSpacing: CGFloat = -0.39 {
        didSet {
            maskingTitleLabel.setTextWithLetterSpacing(string: title ?? "", letterSpacing: letterSpacing)
        }
    }

    var iconSize: CGFloat = CommonConstants.defaultSize {
        didSet {
            iconSizeConstraint.constant = iconSize
            layoutIfNeeded()
        }
    }

    private var wrapContent: Bool = true
    private let gradientImage: UIImage = #imageLiteral(resourceName: "gradientButtonBackground")

    private lazy var textContainerImageView: UIImageView = {

        let view = UIImageView()

        view.image = gradientImage
        view.setContentHuggingPriority(.required, for: .vertical)
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.isUserInteractionEnabled = false
        view.backgroundColor = .white

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var maskingTitleLabel: UILabel = {

        let view = UILabel()

        view.setContentHuggingPriority(.required, for: .vertical)
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.isUserInteractionEnabled = false

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var imageView: UIImageView = {

        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.isUserInteractionEnabled = false
        view.isHidden = true

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var backgroundImageView: UIImageView = {

        let view = UIImageView()
        view.contentMode = .scaleToFill
        view.isUserInteractionEnabled = false

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var stackView: UIStackView = {

        let stackView = UIStackView()

        stackView.distribution = .fillProportionally
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        stackView.setContentHuggingPriority(.required, for: .horizontal)
        stackView.isUserInteractionEnabled = false

        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var zeroWidthConstraint: NSLayoutConstraint = {
        return widthAnchor.constraint(equalToConstant: 0)
    }()

    private lazy var zeroHeightConstraint: NSLayoutConstraint = {
        return heightAnchor.constraint(equalToConstant: 0)
    }()

    private lazy var iconSizeConstraint: NSLayoutConstraint = {
        return imageView.heightAnchor.constraint(equalToConstant: CommonConstants.defaultSize)
    }()

    init(wrapContent: Bool = true,
         buttonSpacing: CGFloat = CommonConstants.tiny) {
        super.init(frame: .zero)

        self.wrapContent = wrapContent
        stackView.spacing = buttonSpacing
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func setupUI() {

        backgroundColor = PAColor.LightestGrey
        clipsToBounds = true

        addSubview(backgroundImageView)
        addSubview(stackView)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(textContainerImageView)
        textContainerImageView.addSubview(maskingTitleLabel)

        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)

        setupConstraints()

        guard wrapContent else {
            setupFillConstraints()
            return
        }

        setupWrapContentConstraints()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        addCornerRadius(cornerRadius: frame.height/2)

        if hasGradientText {
            textContainerImageView.image = gradientImage
        } else {
            textContainerImageView.image = nil
        }

        // setting the mask her to create the gradient text
        textContainerImageView.layer.mask = maskingTitleLabel.layer
        textContainerImageView.layer.masksToBounds = true

    }

    private func setupConstraints() {

        NSLayoutConstraint.activate([

            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),

            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            iconSizeConstraint,

            maskingTitleLabel.topAnchor.constraint(equalTo: textContainerImageView.topAnchor),
            maskingTitleLabel.leadingAnchor.constraint(equalTo: textContainerImageView.leadingAnchor),
            maskingTitleLabel.trailingAnchor.constraint(equalTo: textContainerImageView.trailingAnchor),
            maskingTitleLabel.bottomAnchor.constraint(equalTo: textContainerImageView.bottomAnchor)

        ])
    }

    private func setupFillConstraints() {

        NSLayoutConstraint.activate([

            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)

        ])
    }

    private func setupWrapContentConstraints() {

        NSLayoutConstraint.activate([

            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: CommonConstants.defaultSize),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -CommonConstants.defaultSize)
        ])
    }

    private func setTitle(_ titleText: String?) {
        maskingTitleLabel.setTextWithLetterSpacing(string: titleText ?? "", letterSpacing: letterSpacing)
        textContainerImageView.isHidden = titleText == nil ? true : false
    }

    private func setImage(_ image: UIImage?) {
        imageView.image = image
        imageView.isHidden = image == nil
    }
}
