//
//  PlayerButtonsView.swift
//  Pineapple
//
//  Created by Caoife Davis on 16/12/2022.
//  Copyright © 2022 Pineapple Labs Limited. All rights reserved.
//

import Foundation
import FirebaseFirestore

final class PlayerButtonsView: PassthroughView {

    weak var delegate: PlayerButtonsViewDelegate?

    static let playerButtonsWidth: CGFloat = 56.0

    private var menuItems = [PlayerButtonType]()

    private var likesUserIds: [String] = []

    // likesObservationPath is initially nil when UI is set up and is set later
    var likesObservationPath: String? {
        didSet {

            resetLabels()
            guard let likesObservationPath = likesObservationPath, !likesObservationPath.isEmptyOrOnlyWhitespace() else {
                return
            }

            getLikes(likesObservationPath)
        }
    }

    private lazy var stackView: UIStackView = {

        let stackView = UIStackView()

        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = CommonConstants.defaultSize

        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private var commentsListener: ListenerRegistration?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        commentsListener?.remove()
        commentsListener = nil
    }

    private func setupUI() {

        backgroundColor = .clear
        addSubview(stackView)
        setupConstraints()
    }

    func setupButtons(menuItems: [PlayerButtonType]) {

        self.menuItems = menuItems

        menuItems.forEach {

            let button = PlayerButtonWithMetadataView()

            button.image = $0.iconImage
            button.text = $0.text
            button.iconSize = $0.iconSize
            button.selectedImage = $0.selectedIconImage

            let tapGestureRecognizer: UITapGestureRecognizer

            switch $0 {
            case .comment:
                tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapCommentButton))
            case .like:
                tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapLikeButton))
            case .share:
                tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapShareButton))
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

    private func setupButtonConstraints(_ button: PlayerButtonWithMetadataView) {

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalTo: widthAnchor)
        ])
    }

    @objc private func didTapCommentButton() {
        HapticController.emit(style: .light)
        delegate?.didTapComments()
    }

    @objc private func didTapLikeButton() {

        HapticController.emit(style: .light)
        delegate?.didTapLike()
        toggleLike()
    }

    @objc private func didTapShareButton() {
        HapticController.emit(style: .light)
        delegate?.didTapShare()
    }

    func setLabel(_ text: String? = nil, for buttonType: PlayerButtonType, isSelected: Bool? = nil) {

        guard let buttonView = stackView.arrangedSubviews.getItemSafely(buttonType.rawValue) as? PlayerButtonWithMetadataView else {
            return
        }

        buttonView.text = text ?? buttonView.text

        guard let isSelected = isSelected else { return }
        buttonView.isSelected = isSelected
    }

    private func resetLabels() {

        stackView.arrangedSubviews.enumerated().forEach { index, view in

            let button = view as? PlayerButtonWithMetadataView
            let buttonItem = menuItems.getItemSafely(index)

            button?.text = buttonItem?.text
            button?.isSelected = false
        }
    }

    private func setupLikesUI(likes: [String]) {

        let numberOfLikes = "\(likes.count)"

        let userId = UserController.shared.activeUser?.userId ?? ""
        let hasLiked = likes.contains(userId)

        setLabel(numberOfLikes, for: .like, isSelected: hasLiked)
    }

    func toggleLike() {

        guard let userId = UserController.shared.activeUser?.userId else { return }

        if likesUserIds.contains(where: { $0 == userId }) {
            likesUserIds.removeAll { $0 == userId }
        } else {
            likesUserIds.append(userId)
        }

        setupLikesUI(likes: likesUserIds)
    }

    private func getLikes(_ likesObservationPath: String) {

        guard !likesObservationPath.isEmptyOrOnlyWhitespace() else {
            assertionFailure()
            return
        }

        Task(priority: .high) {

            let userIds = await PostsNetworkHandler.shared.getLikes(collectionPath: likesObservationPath)

            likesUserIds = userIds

            DispatchQueue.main.async { [weak self] in
                self?.setupLikesUI(likes: userIds)
            }
        }
    }

    func observeNumberOfComments(commentsObservationPath: String) {

        guard !commentsObservationPath.isEmptyOrOnlyWhitespace() else {
            assertionFailure()
            return
        }

        let collectionReference = Firestore.firestore().collection(commentsObservationPath)

        commentsListener = collectionReference.addSnapshotListener(includeMetadataChanges: false) { [weak self] querySnapshot, error in

            guard let self = self,
                  error == nil,
                  let snapshot = querySnapshot else {
                return
            }

            let numberOfComments = snapshot.documents.count
            self.setLabel("\(numberOfComments)", for: .comment)
        }
    }
}
