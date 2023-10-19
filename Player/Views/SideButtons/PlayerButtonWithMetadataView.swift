//
//  PlayerButtonWithMetadataView.swift
//  Pineapple
//
//  Created by Caoife Davis on 16/12/2022.
//  Copyright © 2022 Pineapple Labs Limited. All rights reserved.
//

import Foundation

final class PlayerButtonWithMetadataView: UIControl {

    private let highlightedOpacity: CGFloat = 0.6
    private let labelLetterSpacing: CGFloat = -0.68
    private let dropShadowOpacity: Float = 0.28
    private let dropShadowRadius: CGFloat = 6
    private let blurRadius: CGFloat = 0.25
    private let dropShadowOffset: CGSize = CGSize(width: 0, height: 3)

    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? highlightedOpacity : 1.0
        }
    }

    override var isSelected: Bool {
        didSet {
            iconImageView.image = isSelected ? selectedImage : image
        }
    }

    var text: String? {
        didSet {

            guard let text = text else {
                label.isHidden = true
                return
            }

            label.isHidden = false
            label.setTextWithLetterSpacing(string: text, letterSpacing: labelLetterSpacing)
        }
    }

    var image: UIImage? {
        didSet {
            iconImageView.image = image
        }
    }

    var iconSize: CGFloat = 0 {
        didSet {
            setIconSize()
        }
    }

    var selectedImage: UIImage?

    private lazy var label: UILabel = {

        let label = UILabel()

        label.textAlignment = .left
        label.numberOfLines = 1
        label.font = PAFont.Font14Heavy
        label.textColor = .white
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.isHidden = true
        label.addDropShadow(withRadius: dropShadowRadius,
                            offset: dropShadowOffset,
                            opacity: dropShadowOpacity)
        label.isUserInteractionEnabled = false

        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var blurBackgroundView: BlurView = {

        let blurEffect = UIBlurEffect(style: .systemThickMaterialDark)
        let blurView = BlurView(blurEffect: blurEffect, blurRadius: blurRadius)
        blurView.backgroundColor = .clear
        blurView.layer.masksToBounds = true
        blurView.isUserInteractionEnabled = false

        blurView.translatesAutoresizingMaskIntoConstraints = false
        return blurView
    }()

    private lazy var iconImageView: UIImageView = {

        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.addDropShadow(withRadius: dropShadowRadius,
                            offset: dropShadowOffset,
                            opacity: dropShadowOpacity)
        view.isUserInteractionEnabled = false

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var stackView: UIStackView = {

        let stackView = UIStackView()

        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = CommonConstants.tiny
        stackView.alignment = .center
        stackView.isUserInteractionEnabled = false

        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        blurBackgroundView.addCornerRadius(cornerRadius: frame.width/2)
    }

    private func setupUI() {

        addSubview(stackView)
        stackView.addArrangedSubview(blurBackgroundView)
        stackView.addArrangedSubview(label)
        blurBackgroundView.contentView.addSubview(iconImageView)

        setupConstraints()
    }

    private func setupConstraints() {

        NSLayoutConstraint.activate([

            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),

            iconImageView.centerXAnchor.constraint(equalTo: blurBackgroundView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: blurBackgroundView.centerYAnchor),

            blurBackgroundView.heightAnchor.constraint(equalTo: widthAnchor),
            blurBackgroundView.widthAnchor.constraint(equalTo: widthAnchor)
        ])
    }

    private func setIconSize() {

        NSLayoutConstraint.activate([
            iconImageView.heightAnchor.constraint(equalToConstant: iconSize),
            iconImageView.widthAnchor.constraint(equalToConstant: iconSize)
        ])

        layoutIfNeeded()
    }
}
