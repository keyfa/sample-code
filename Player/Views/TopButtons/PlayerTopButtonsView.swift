//
//  PlayerTopButtonsView.swift
//  Pineapple
//
//  Created by Caoife Davis on 16/12/2022.
//  Copyright © 2022 Pineapple Labs Limited. All rights reserved.
//

import Foundation

final class PlayerTopButtonsView: PassthroughView {

    weak var delegate: PlayerTopButtonsViewDelegate?

    private let buttonsWidth: CGFloat = 53.0

    var buttonItems: [PlayerTopButtonType] = PlayerTopButtonType.allCases {
        didSet {
            PlayerTopButtonType.allCases.forEach {
                let shouldHide = !buttonItems.contains($0)
                isHidden(shouldHide, for: $0)
            }
        }
    }

    private lazy var stackView: UIStackView = {

        let stackView = UIStackView()

        stackView.distribution = .fill
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = CommonConstants.small

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

    private func setupUI() {

        backgroundColor = .clear
        addSubview(stackView)
        setupStackView()
        setupConstraints()
    }

    private func setupStackView() {

        PlayerTopButtonType.allCases.forEach {

            let button = IconButtonWithBlurredBackground()

            button.image = $0.iconImage
            button.iconSize = $0.iconSize

            let tapGestureRecognizer: UITapGestureRecognizer

            switch $0 {
            case .action:
                tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapActionButton))
            case .share:
                tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapShareButton))
            case .report:
                tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapReportButton))
            }

            button.addGestureRecognizer(tapGestureRecognizer)
            stackView.addArrangedSubview(button)
            setupButtonConstraints(button)
        }
    }

    private func setupConstraints() {

        NSLayoutConstraint.activate([

            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    private func setupButtonConstraints(_ button: IconButtonWithBlurredBackground) {

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: buttonsWidth),
            button.heightAnchor.constraint(equalTo: heightAnchor)
        ])
    }

    @objc private func didTapReportButton() {
        HapticController.emit(style: .light)
        delegate?.didTapReportButton()
    }

    @objc private func didTapShareButton() {
        HapticController.emit(style: .light)
        delegate?.didTapShareButton()
    }

    @objc private func didTapActionButton() {
        HapticController.emit(style: .light)
        delegate?.didTapActionButton()
    }

    private func isHidden(_ isHidden: Bool, for buttonType: PlayerTopButtonType) {

        guard let buttonView = stackView.arrangedSubviews.getItemSafely(buttonType.rawValue) as? IconButtonWithBlurredBackground else {
            return
        }

        buttonView.isHidden = isHidden
    }
}
