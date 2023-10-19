//
//  OpportunitiesCoordinator.swift
//  Pineapple
//
//  Created by Caoife Davis on 09/03/2023.
//  Copyright © 2023 Pineapple Labs Limited. All rights reserved.
//

import Foundation

final class OpportunitiesCoordinator: Coordinator {

    private var childCoordinators = [Coordinator]()
    var completionHandler: CoordinatorCompletionHandler?
    var navigationController: UINavigationController

    let viewController: OpportunitiesViewController
    let interactor: OpportunitiesInteractor
    let presenter: OpportunitiesPresenter

    private var shouldRefreshOpportunities: Bool = true
    private let hideSuggestionsBannerAfterDuration: CGFloat = 3.0
    private var shownDuringUserJourney: Bool = false

    init(navigationController: UINavigationController) {

        self.navigationController = navigationController
        viewController = OpportunitiesViewController()
        presenter = OpportunitiesPresenter(viewController: viewController)
        interactor = OpportunitiesInteractor(presenter: presenter)

        viewController.delegate = self

        start(completionHandler: nil)
        setupObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func setupObservers() {

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(scrollToTop),
                                               name: NSNotification.Name(PAConstant.Notification.tabBarControllerRequestedScrollToTop),
                                               object: nil)
    }

    func start(completionHandler: CoordinatorCompletionHandler?) {
        self.completionHandler = completionHandler
        navigationController.pushViewController(viewController, animated: true)
    }

    @objc func scrollToTop() {
        Task { await presenter.scrollToTop() }
    }
}

extension OpportunitiesCoordinator: OpportunitiesViewControllerDelegate {

    func getSelectedFilter() -> OpportunityFilter? {
        return interactor.selectedFilter
    }

    func didTapSearch() {

        let searchCoordinator = SearchCoordinator(navigationController: navigationController)

        searchCoordinator.start { [weak self] in
            self?.childCoordinators.removeAll { $0 is SearchCoordinator}
        }
        searchCoordinator.delegate = self

        childCoordinators.append(searchCoordinator)
    }

    func getLocationIdsFilter() -> [String] {
        return interactor.selectedFilter?.locationIds ?? []
    }

    func isOpenForHighschoolersFilterApplied() -> Bool {
        return interactor.selectedFilter?.isOpenForHighschoolers ?? false
    }

    func clearAllFilters() {
        didAddFilters(selectedFilter: nil)
    }

    func updateTypeFilter() {
        interactor.updateTypeFilter()
    }

    func clearTypeFilter() {
        interactor.clearTypeFilter()
    }

    func didSelectTypeFilterItem(withId id: String) {
        interactor.didSelectTypeFilterItem(withId: id)
    }

    func didDeselectTypeFilterItem(withId id: String) {
        interactor.didDeselectTypeFilterItem(withId: id)
    }

    func getSectionCount() -> Int {
        return OpportunitiesSectionType.allCases.count
    }

    func getNumberOfRows(in section: Int) -> Int {

        guard let sectionType = getSectionType(for: section) else {
            return 0
        }
        return interactor.getNumberOfRows(in: sectionType)
    }

    func getSectionType(for section: Int) -> OpportunitiesSectionType? {
        return OpportunitiesSectionType(rawValue: section)
    }

    func getOpportunityItem(at row: Int) -> Opportunity? {
        return interactor.getOpportunityItem(at: row)
    }

    func loadMoreOpportunities() {
        guard shouldRefreshOpportunities else { return }
        interactor.fetchMoreOpportunities()
    }

    func didTapActivityFeedButton() {

        let activityFeedCoordinator = ActivityFeedCoordinator(navigationController: navigationController)

        activityFeedCoordinator.start { [weak self] in
            self?.childCoordinators.removeAll {$0 is ActivityFeedCoordinator}
        }

        childCoordinators.append(activityFeedCoordinator)
    }

    func refreshData() {
        guard shouldRefreshOpportunities else { return }
        interactor.refreshData()
    }

    func goToConversations() {

        let coordinator = UserConversationsCoordinator(navigationController: navigationController)

        coordinator.start { [weak self] in
            self?.childCoordinators.removeAll { $0 is UserConversationsCoordinator}
        }

        childCoordinators.append(coordinator)
    }

    func didTapOpportunity(opportunity: Opportunity) {

        SegmentUtil.trackEvent()?.opportunityCardTapped(opportunityId: opportunity.id)

        let applyToOpportunityCoordinator = ApplyToOpportunityDrawerCoordinator(navigationController: navigationController, opportunity: opportunity)

        applyToOpportunityCoordinator.delegate = self
        applyToOpportunityCoordinator.start { [weak self] in
            self?.childCoordinators.removeAll { $0 is ApplyToOpportunityDrawerCoordinator}
            self?.didDismissApplyToOpportunity()
        }

        childCoordinators.append(applyToOpportunityCoordinator)
    }

    func goToOpportunityFilters() {

        let coordinator = OpportunitiesFilterCoordinator(navigationController: navigationController,
                                                        selectedFilter: interactor.selectedFilter)
        coordinator.delegate = self

        coordinator.start { [weak self] in
            self?.childCoordinators.removeAll { $0 is OpportunitiesFilterCoordinator}
        }

        childCoordinators.append(coordinator)
    }

    func openLocationsFilterDrawer() {

        let coordinator = OpportunityLocationDrawerCoordinator(navigationController: navigationController, selectedOpportunityLocationIds: interactor.selectedLocationIds)

        coordinator.delegate = self
        coordinator.start { [weak self] in
            self?.childCoordinators.removeAll { $0 is OpportunityLocationDrawerCoordinator}
        }

        childCoordinators.append(coordinator)
    }

    func didTapSavedButton() {
        
        let coordinator = YourOpportunitiesCoordinator(navigationController: navigationController)
        
        coordinator.start { [weak self] in
            self?.childCoordinators.removeAll {$0 is YourOpportunitiesCoordinator}
        }
        
        childCoordinators.append(coordinator)
    }
}

extension OpportunitiesCoordinator: OpportunitiesFilterDelegate {

    func didAddFilters(selectedFilter: OpportunityFilter?) {
        interactor.applyFilters(selectedFilter: selectedFilter)
        interactor.updateTypeFilter()
    }
}

extension OpportunitiesCoordinator: OpportunityLocationDrawerDelegate {

    func didTapSaveLocations(locationIds: [String]) {
        interactor.didSelectLocationFilter(withIds: locationIds)
    }
}

extension OpportunitiesCoordinator: ApplyToOpportunityDrawerDelegate, SearchCoordinatorDelegate, WebViewCoordinatorDelegate {

    func goToOpportunity(stringUrl: String, opportunityId: String) {

        guard let url = URL(string: stringUrl) else { return }

        let bottomNavBar = OpportunitiesWebViewBottomNavigationBar(opportunityId: opportunityId)

        let webViewCoordinator = WebViewCoordinator(navigationController: navigationController,
                                                    url: url,
                                                    bottomNavigationBar: bottomNavBar,
                                                    opportunityId: opportunityId)
        webViewCoordinator.delegate = self

        webViewCoordinator.start { [weak self] in

            self?.childCoordinators.removeAll { $0 is WebViewCoordinator }

            guard let opportunity = OpportunitiesLocalDBHandler.shared.loadOpportunity(with: opportunityId) else {
                self?.didDismissApplyToOpportunity()
                return
            }

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(reopenDrawerDelayTimeInMS)) {
                self?.didTapOpportunity(opportunity: opportunity)
            }
        }

        childCoordinators.append(webViewCoordinator)

    }

    private func didDismissApplyToOpportunity() {

        Task {
            await presenter.viewController.showExploreNeworkingUserJourneyToolTipIfNeeded()
        }
    }

    func goToSavedOpportunities() {
        didTapSavedButton()
    }
}
