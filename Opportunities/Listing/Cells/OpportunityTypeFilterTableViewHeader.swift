//
//  OpportunityTypeFilterTableViewHeader.swift
//  Pineapple
//
//  Created by Caoife Davis on 18/03/2023.
//  Copyright © 2023 Pineapple Labs Limited. All rights reserved.
//

import Foundation

protocol OpportunityTypeFilterTableViewHeaderDelagate: AnyObject {

    func didClearTypeFilter()
    func didSelectFilterItem(withId id: String)
    func didDeselectFilterItem(withId id: String)
}

protocol OpportunityTypeFilterHeaderDelegate: AnyObject {
    func setSelectedFilterItems(selectedTypeIds: [String])
}

final class OpportunityTypeFilterTableViewHeader: UITableViewHeaderFooterView {

    weak var delegate: OpportunityTypeFilterTableViewHeaderDelagate?

    static let height: CGFloat = 60.0

    private let numberOfLoadingItems: Int = 6
    private let clearButtonAnimationDuration: CGFloat = 0.25
    private let clearButtonWidth: CGFloat = 84.0

    private let clearButtonText = " clear"

    private var opportunityTypes = OpportunitiesLocalDBHandler.shared.loadOpportunityTypes()

    private let collectionViewContentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: CommonConstants.defaultSize)
    private let gradientStartPoint: CGPoint = CGPoint(x: 0, y: 0.0)
    private let gradientEndPoint: CGPoint = CGPoint(x: 0.1, y: 0.0)

    private let flowLayout: UICollectionViewFlowLayout = {

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.estimatedItemSize = CGSize(width: 0, height: InterestCollectionViewCell.cellHeight)
        return flowLayout
    }()

    private lazy var collectionView: UICollectionView = {

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.allowsMultipleSelection = true
        collectionView.registerCell(PillCollectionViewCell.self)
        collectionView.clipsToBounds = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = collectionViewContentInset

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private lazy var clearButton: UIButton = {

        let button = UIButton()
        button.addTarget(self, action: #selector(didTapClearButton), for: .touchUpInside)
        button.setImage(#imageLiteral(resourceName: "closeIconBlue"), for: .normal)
        button.isHidden = true
        button.setTitle(clearButtonText, for: .normal)
        button.titleLabel?.font = PAFont.Font15Bold
        button.titleLabel?.changeLetterSpacing()
        button.setTitleColor(PAColor.lightBlue, for: .normal)
        button.backgroundColor = PAColor.LightestGrey
        button.addCornerRadius(cornerRadius: PillCollectionViewCell.cellHeight/2)

        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var stackView: UIStackView = {

        let stackView = UIStackView()

        stackView.distribution = .fill
        stackView.axis = .horizontal
        stackView.alignment = .center

        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var gradientView: LinearGradientView = {

        let view = LinearGradientView(colors: [UIColor.white.cgColor, UIColor.white.withAlphaComponent(0).cgColor],
                                      startPoint: gradientStartPoint,
                                      endPoint: gradientEndPoint)
        view.alpha = 0

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupLayout()
        setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupObservers() {

        guard opportunityTypes.isEmpty else { return }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadOpportunityTypes),
                                               name: NSNotification.Name(opportunityTypesLoadedNotification),
                                               object: nil)

        Task(priority: .high) { await OpportunitiesNetworkHandler.shared.getOpportunityTypes() }
    }

    private func setupLayout() {

        contentView.backgroundColor = .white

        addSubview(stackView)
        stackView.addArrangedSubview(clearButton)
        stackView.addArrangedSubview(collectionView)

        stackView.bringSubviewToFront(clearButton)
        addSubview(gradientView)

        setupConstraints()
    }

    private func setupConstraints() {

        NSLayoutConstraint.activate([

            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: CommonConstants.defaultSize),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),

            collectionView.heightAnchor.constraint(equalToConstant: PillCollectionViewCell.cellHeight),

            clearButton.heightAnchor.constraint(equalToConstant: PillCollectionViewCell.cellHeight),
            clearButton.widthAnchor.constraint(equalToConstant: clearButtonWidth),

            gradientView.topAnchor.constraint(equalTo: collectionView.topAnchor),
            gradientView.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor),
            gradientView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor)
        ])
    }

    private func animateClearButtonVisibility(isHidden: Bool) {

        collectionView.clipsToBounds = !isHidden
        collectionView.contentInset.left = isHidden ? 0 : CommonConstants.defaultSize

        guard clearButton.isHidden != isHidden else { return }

        UIView.animate(withDuration: clearButtonAnimationDuration, delay: 0, options: [.allowUserInteraction]) { [weak self] in

            self?.clearButton.isHidden = isHidden
            self?.clearButton.alpha = isHidden ? 0 : 1
            self?.gradientView.alpha = isHidden ? 0 : 1
        }
    }

    @objc private func reloadOpportunityTypes() {

        opportunityTypes = OpportunitiesLocalDBHandler.shared.loadOpportunityTypes()
        collectionView.reloadData()

        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name(opportunityTypesLoadedNotification),
                                                  object: nil)
    }

    @objc private func didTapClearButton() {

        animateClearButtonVisibility(isHidden: true)
        delegate?.didClearTypeFilter()
        collectionView.reloadData()
    }
}

extension OpportunityTypeFilterTableViewHeader: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(PillCollectionViewCell.self, for: indexPath)
        let type = opportunityTypes.getItemSafely(indexPath.row)
        cell.setupUI(title: type?.title)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        opportunityTypes.isEmpty ? numberOfLoadingItems : opportunityTypes.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard let type = opportunityTypes.getItemSafely(indexPath.row) else { return }

        animateClearButtonVisibility(isHidden: false)

        delegate?.didSelectFilterItem(withId: type.id)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {

        guard let type = opportunityTypes.getItemSafely(indexPath.row) else { return }

        delegate?.didDeselectFilterItem(withId: type.id)

        guard collectionView.indexPathsForSelectedItems?.isEmpty == true else { return }

        animateClearButtonVisibility(isHidden: true)
    }
}

extension OpportunityTypeFilterTableViewHeader: OpportunityTypeFilterHeaderDelegate {

    func setSelectedFilterItems(selectedTypeIds: [String]) {

        collectionView.deselectAllItems(animated: false)

        let selectedIndexes: [IndexPath] = selectedTypeIds.compactMap { selectedTypeId in

            guard let index = opportunityTypes.firstIndex( where: { selectedTypeId == $0.id }) else {
                return nil
            }

            return IndexPath(row: index, section: 0)
        }

        selectedIndexes.forEach {
            collectionView.selectItem(at: $0, animated: false, scrollPosition: [])
        }

        animateClearButtonVisibility(isHidden: selectedTypeIds.isEmpty)
    }
}
