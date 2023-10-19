//
//  OpportunitiesFilterViewController.swift
//  Pineapple
//
//  Created by Caoife Davis on 16/03/2023.
//  Copyright © 2023 Pineapple Labs Limited. All rights reserved.
//

import Foundation

final class OpportunitiesFilterViewController: UIViewController {

    weak var delegate: OpportunitiesFilterViewControllerDelegate?

    private let collectionViewHorizontalSpacing: CGFloat = CommonConstants.large
    private let letterSpacing: CGFloat = -0.48
    private let titleLetterSpacing: CGFloat = -0.75
    private let titleLineHeight: CGFloat = 38.0
    private let doneButtonHeight: CGFloat = 47.0
    private let blurRadius: CGFloat = 20.0

    private let titleText = "filter"
    private let clearButtonText = "Clear Filters"
    private let doneButtonText = "done"

    private let collectionViewContentInset = UIEdgeInsets(top: 0, left: 0, bottom: 110, right: 0)

    private var flowLayout: LeftAlignedCollectionViewFlowLayout = {

        let flowLayout = LeftAlignedCollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.estimatedItemSize = CGSize(width: 0, height: InterestCollectionViewCell.cellHeight)
        return flowLayout
    }()

    private lazy var titleLabel: UILabel = {

        let label = UILabel()

        label.textAlignment = .left
        label.numberOfLines = 1
        label.font = PAFont.Font20Bold
        label.setTextWithLetterSpacing(string: titleText,
                                       letterSpacing: letterSpacing)

        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var backButton: LargeHitZoneButton = {

        let button = LargeHitZoneButton()

        button.imageView?.contentMode = .scaleAspectFill
        button.setImage(#imageLiteral(resourceName: "backChevronIconBlue"), for: .normal)
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchDown)

        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var clearButton: UIButton = {

        let button = UIButton()

        button.backgroundColor = .clear
        button.setTitleColor(PAColor.lightBlue, for: .normal)
        button.setTitle(clearButtonText, for: .normal)
        button.titleLabel?.font = PAFont.Font17Regular
        button.titleLabel?.changeLetterSpacing(kernValue: letterSpacing)
        button.addTarget(self, action: #selector(didTapClearButton), for: .touchUpInside)

        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private(set) lazy var collectionView: UICollectionView = {

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.allowsMultipleSelection = true
        collectionView.registerCell(PillCollectionViewCell.self)
        collectionView.registerCell(FilterCollectionViewCell.self)
        collectionView.registerReusableView(HeaderCollectionReuseableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        collectionView.isScrollEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = collectionViewContentInset
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        return collectionView
    }()

    private lazy var doneButtonContainerView: BlurView = {

        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        let view = BlurView(blurEffect: blurEffect, blurRadius: blurRadius)

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var doneButton: PineappleGradientButton = {

        let button = PineappleGradientButton(wrapContent: false)

        button.hasGradientText = false
        button.title = doneButtonText
        button.font = PAFont.Font15Heavy
        button.titleColour = .white
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)

        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
        setUpUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.isHidden = true
        AppCoordinator.shared.tabBarController.setTabBarHidden(true)
        delegate?.viewWillAppear()
    }

    func setUpUI() {

        view.backgroundColor = .white

        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(clearButton)
        view.addSubview(collectionView)
        view.addSubview(doneButtonContainerView)
        view.addSubview(doneButton)

        setupConstraints()
    }

    func setupConstraints() {

        NSLayoutConstraint.activate([

            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: CommonConstants.small),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CommonConstants.defaultSize),
            backButton.widthAnchor.constraint(equalToConstant: CommonConstants.medium),

            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: CommonConstants.defaultSize),

            clearButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -CommonConstants.defaultSize),
            clearButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),

            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: collectionViewHorizontalSpacing),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -collectionViewHorizontalSpacing),

            doneButtonContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            doneButtonContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            doneButtonContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            doneButton.topAnchor.constraint(equalTo: doneButtonContainerView.topAnchor, constant: CommonConstants.large),
            doneButton.bottomAnchor.constraint(equalTo: doneButtonContainerView.bottomAnchor, constant: -CommonConstants.massive),
            doneButton.leadingAnchor.constraint(equalTo: doneButtonContainerView.leadingAnchor, constant: CommonConstants.large),
            doneButton.trailingAnchor.constraint(equalTo: doneButtonContainerView.trailingAnchor, constant: -CommonConstants.large),
            doneButton.heightAnchor.constraint(equalToConstant: doneButtonHeight)
        ])
    }

    @objc private func didTapBackButton() {
        delegate?.backButtonTapped()
    }

    @objc private func didTapClearButton() {
        delegate?.clearSelection()
    }
}

extension OpportunitiesFilterViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        return CGSize(width: collectionView.frame.size.width,
                      height: HeaderCollectionReuseableView.height)
    }
}

extension OpportunitiesFilterViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return delegate?.getNumberOfSections() ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate?.getItemCount(section: section) ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        guard let sectionTitle = delegate?.getSectionTitle( indexPath.section) else {
            return collectionView.dequeueReusableSupplementaryView(HeaderCollectionReuseableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, for: indexPath)
        }

        let header = collectionView.dequeueReusableSupplementaryView(HeaderCollectionReuseableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, for: indexPath)
        header.setupUI(title: sectionTitle)

        return header
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let section = delegate?.getSectionType(section: indexPath.section) else {
            return collectionView.dequeueReusableCell(PillCollectionViewCell.self, for: indexPath)
        }

        switch section {

        case .openToHighSchoolers, .location:

            let title = delegate?.getItemTitle(at: indexPath) ?? ""

            let cell: FilterCollectionViewCell = collectionView.dequeueReusableCell(FilterCollectionViewCell.self, for: indexPath)
            cell.setupUI(title: title)
            cell.horizontalSpacing = collectionViewHorizontalSpacing

            if section == .openToHighSchoolers {
                cell.isCheckBoxHidden = false
                cell.isChevronHidden = true
            }

            return cell
        case .type, .industry:

            let cell: PillCollectionViewCell = collectionView.dequeueReusableCell(PillCollectionViewCell.self, for: indexPath)
            let title = delegate?.getItemTitle(at: indexPath)
            cell.setupUI(title: title)

            return cell
        }
    }
}

extension OpportunitiesFilterViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section == OpportunityFilterSections.location.rawValue else { return }
        delegate?.showLocationSelection()
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard indexPath.section == OpportunityFilterSections.location.rawValue else { return }
        delegate?.showLocationSelection()
    }
}
