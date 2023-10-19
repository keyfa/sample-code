//
//  OpportunitiesViewController.swift
//  Pineapple
//
//  Created by Caoife Davis on 09/03/2023.
//  Copyright © 2023 Pineapple Labs Limited. All rights reserved.
//

import Foundation
import CoreData

final class OpportunitiesViewController: UIViewController, NSFetchedResultsControllerDelegate {

    weak var delegate: OpportunitiesViewControllerDelegate?
    weak var limitOpportunitiesDelegate: OpportunitiesLimitedDelegate?
    weak var oppotunityTypeFilterDelegate: OpportunityTypeFilterHeaderDelegate?

    private let numberOfItemsBeforeReloading: Int = 4
    private let endTourBottomDistance: CGFloat = 110
    private let dropShadowOpacity: Float = 0.25
    private let dropShadowRadius: CGFloat = 4
    private let dropShadowOffset: CGSize = CGSize(width: 0, height: 4)

    private let titleText = "opportunities"

    private lazy var topNavigationBar: TopNavigationBarView = {

        let navBar = TopNavigationBarView()
        navBar.title = titleText
        navBar.hideSettingsButton = true

        navBar.translatesAutoresizingMaskIntoConstraints = false
        return navBar
    }()

    private(set) lazy var tableView: UITableView = {

        let tableView = UITableView(frame: .zero, style: .plain)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false

        tableView.sectionFooterHeight = 0.0

        if #available(iOS 15.0, *) {
            tableView.isPrefetchingEnabled = false
            tableView.sectionHeaderTopPadding = .leastNormalMagnitude
        }
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        delegate?.refreshData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.isHidden = true
        AppCoordinator.shared.tabBarController.setTabBarHidden(false)
    }

    private func setupUI() {

        topNavigationBar.setupUI(delegate: self)

        addRefreshControl()
        view.backgroundColor = .white
        topNavigationBar.backgroundColor = .white

        view.addSubview(tableView)
        view.addSubview(topNavigationBar)

        setupTableView()
        setupConstraints()
    }

    private func addRefreshControl() {

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    @objc private func refreshData() {
        delegate?.refreshData()
    }

    private func setupTableView() {

        tableView.registerCell(SearchBarTableViewCell.self)
        tableView.registerCell(OpportunityListingTableViewCell.self)
        tableView.registerCell(BottomLoaderTableViewCell.self)
        tableView.registerCell(FeedLoadingCell.self)
        tableView.registerCell(OpportunitesLimitedTableViewCell.self)
        tableView.registerCell(OpportunityFilterTableViewCell.self)
        tableView.registerHeader(OpportunityTypeFilterTableViewHeader.self)
        tableView.registerCell(OpportunityEmptyStateTableViewCell.self)
        tableView.registerCell(OpportunitySuggestionsBannerTableviewCell.self)
    }

    private func setupConstraints() {

        NSLayoutConstraint.activate([

            topNavigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topNavigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -CommonConstants.small),
            topNavigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -CommonConstants.defaultSize),
            topNavigationBar.heightAnchor.constraint(equalToConstant: TopNavigationBarView.defaultHeight),

            tableView.topAnchor.constraint(equalTo: topNavigationBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func showToastError() {

        showToastView(on: view,
                      with: PineappleError.toastError.displayedError,
                      shouldDisplayCheckMark: false,
                      displayOnTabBar: false,
                      shouldHideAutomatically: true)
    }
}

extension OpportunitiesViewController: TopNavigationBarViewDelegate {

    func didTapActivityFeedButton() {
        delegate?.didTapActivityFeedButton()
    }

    func didTapChatButton() {
        delegate?.goToConversations()
    }

    func didTapSavedButton() {
        delegate?.didTapSavedButton()
    }
}

extension OpportunitiesViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return delegate?.getSectionCount() ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate?.getNumberOfRows(in: section) ?? 0
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        let type = delegate?.getSectionType(for: section)

        guard type == .opportunities else { return 0 }

        return OpportunityTypeFilterTableViewHeader.height
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let type = delegate?.getSectionType(for: section)

        guard type == .opportunities else { return nil }

        let header = tableView.dequeueReusableHeader(OpportunityTypeFilterTableViewHeader.self)
        header.delegate = self
        oppotunityTypeFilterDelegate = header

        return header
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let sectionType = delegate?.getSectionType(for: indexPath.section) else {
            return tableView.dequeueReusableCell(UITableViewCell.self, for: indexPath)
        }

        switch sectionType {

        case .search:

            let cell = tableView.dequeueReusableCell(SearchBarTableViewCell.self, for: indexPath)
            cell.setupUI()
            return cell
        case .filter:

            let cell = tableView.dequeueReusableCell(OpportunityFilterTableViewCell.self, for: indexPath)
            cell.delegate = self

            let selectedFilter = delegate?.getSelectedFilter()

            let isHighSchoolFilterSelected = selectedFilter?.isOpenForHighschoolers ?? false
            let loctionIds = selectedFilter?.locationIds ?? []
            let industryIds = selectedFilter?.industryIds ?? []
            cell.setupUI(locationIds: loctionIds, isHighSchoolFilterSelected: isHighSchoolFilterSelected, industriesIds: industryIds)

            return cell

        case .setUp:

            let cell = tableView.dequeueReusableCell(OpportunitySuggestionsBannerTableviewCell.self, for: indexPath)
            return cell
        case .opportunities:

            let opportunity = delegate?.getOpportunityItem(at: indexPath.row)

            let cell: OpportunityListingTableViewCell = tableView.dequeueReusableCell(OpportunityListingTableViewCell.self, for: indexPath)

            let isFirstElement = indexPath.row == 0
            let isLastElement = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1

            cell.setupUI(opportunity, isFirstElement: isFirstElement, isLastElement: isLastElement )

            return cell

        case .opportunitiesLimited:

            let cell: OpportunitesLimitedTableViewCell = tableView.dequeueReusableCell(OpportunitesLimitedTableViewCell.self, for: indexPath)
            cell.delegate = self
            limitOpportunitiesDelegate = cell

            return cell
        case .empty:

            guard UserController.shared.activeUser?.canAccessAllOpportunities == true else {

                let cell: OpportunitesLimitedTableViewCell = tableView.dequeueReusableCell(OpportunitesLimitedTableViewCell.self, for: indexPath)
                cell.delegate = self
                limitOpportunitiesDelegate = cell
                return cell
            }

            let cell = tableView.dequeueReusableCell(OpportunityEmptyStateTableViewCell.self, for: indexPath)
            cell.setupUI(.all)
            cell.delegate = self

            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let section = delegate?.getSectionType(for: indexPath.section) else {
            return
        }

        switch section {

        case .search:
            delegate?.didTapSearch()
        case .setUp:
            SegmentUtil.trackEvent()?.setUpBannerTapped()
            delegate?.didTapSuggestionsBanner()
        case .opportunities:
            guard let opportunity = delegate?.getOpportunityItem(at: indexPath.row) else { return }
            delegate?.didTapOpportunity(opportunity: opportunity)
            removeUserJourneyOpportunityListingUI()
        default:
            return
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let lastSectionIndex = tableView.numberOfSections - 1

        guard let lastVisibleIndexPath = tableView.indexPathsForVisibleRows?.last,
              lastSectionIndex >= 0 else {
            return
        }

        let lastRowBeforeLoading = tableView.numberOfRows(inSection: lastSectionIndex) - numberOfItemsBeforeReloading
        let isRowCloseEnoughForNewPage = lastVisibleIndexPath.row > lastRowBeforeLoading

        if isRowCloseEnoughForNewPage && tableView.isDragging {
            delegate?.loadMoreOpportunities()
        }
    }
}

extension OpportunitiesViewController: OpportunitesLimitedTableViewCellDelegate {

    func didTapReferralButton() {

        showReferralShareSheet { [weak self] in
            self?.limitOpportunitiesDelegate?.canAccessOpportunities()
        }

        UserController.shared.activeUser?.canAccessAllOpportunities = true
        UserNetworkController.updateUserData()
    }

    func didTapShowMoreOpportunities() {
        delegate?.loadMoreOpportunities()
    }
}

extension OpportunitiesViewController: OpportunityTypeFilterTableViewHeaderDelagate {

    func didClearTypeFilter() {
        delegate?.clearTypeFilter()
    }

    func didSelectFilterItem(withId id: String) {
        delegate?.didSelectTypeFilterItem(withId: id)
    }

    func didDeselectFilterItem(withId id: String) {
        delegate?.didDeselectTypeFilterItem(withId: id)
    }
}

extension OpportunitiesViewController: OpportunityFilterTableViewCellDelegate {

    func didTapLocationsFilter() {
        delegate?.openLocationsFilterDrawer()
    }

    func didTapMoreFilters() {
        delegate?.goToOpportunityFilters()
    }
}

extension OpportunitiesViewController: OpportunityEmptyStateDelegate {

    func didTapGradientButton() {
        delegate?.clearAllFilters()
    }
}
