//
//  OpportunitiesInteractor.swift
//  Pineapple
//
//  Created by Caoife Davis on 09/03/2023.
//  Copyright © 2023 Pineapple Labs Limited. All rights reserved.
//

import Foundation
import CoreData

final class OpportunitiesInteractor {

    private let presenter: OpportunitiesPresenter
    private let fetchedResultsController: OpportunitiesFetchedResultsController

    private var lastRequestedTimestamp = Double.greatestFiniteMagnitude

    private var currentTimestamp: Double {
        get {
            Double(Date().timeIntervalSince1970)
        }
    }

    private let pageSizeForPagination: Int = 20
    private let maxNumOfOpportunitiesIfLimited: Int = 15
    private var isLoading = false

    private(set) var selectedFilter: OpportunityFilter?

    var selectedLocationIds: [String]? {
        get {
            return selectedFilter?.locationIds
        }
    }

    var opportunitiesCount: Int {
        get {
            fetchedResultsController.opportunitiesCount
        }
    }

    private var hasAppliedFilter: Bool {
        get {
            fetchedResultsController.hasAppliedFilter
        }
    }

    private var canAccessAllOpportunities: Bool {
        get {
            UserController.shared.activeUser?.canAccessAllOpportunities == true
        }
    }

    init(presenter: OpportunitiesPresenter) {

        self.presenter = presenter
        self.fetchedResultsController = OpportunitiesFetchedResultsController(batchSize: pageSizeForPagination)

        setupObservers()
        OpportunitiesLocalDBHandler.shared.deleteOpportunities()
        fetchedResultsController.delegate = presenter.viewController
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupObservers() {

        NotificationCenter.default.addObserver(self, selector: #selector(didSaveOpportunitiesData),
                                               name: NSNotification.Name(opportunitiesLoadedNotification),
                                               object: nil)
    }

    func refreshData() {
        refreshOpportunitiesData()
    }

    private func refreshOpportunitiesData() {
        fetchOpportunitiesData(timestamp: currentTimestamp)
    }

    func fetchMoreOpportunities() {

        let lastOpportunity = fetchedResultsController.fetchedObjects?.last

        let timestamp: Double

        if canAccessAllOpportunities, let lastTimestamp = lastOpportunity?.timestamp {
            timestamp = lastTimestamp
        } else {
            timestamp = currentTimestamp
        }

        fetchOpportunitiesData(timestamp: timestamp)
    }

    private func fetchOpportunitiesData(timestamp: Double) {

        guard !isLoading else {
            return
        }

        lastRequestedTimestamp = timestamp

        isLoading = true

        Task(priority: .userInitiated) {

            do {

                try await OpportunitiesNetworkHandler.shared.getOpportunities(allDataBeforeTimestamp: timestamp,
                                                                              selectedFilter: selectedFilter,
                                                                              pageSize: pageSizeForPagination)
                isLoading = false
            } catch {
                isLoading = false
                await presenter.showToastError()
            }
        }
    }

    @objc func didSaveOpportunitiesData() {

        do {
            try fetchedResultsController.performFetchAndCacheImages(batchSize: pageSizeForPagination)
            Task { await presenter.reloadOpportunitySections() }
        } catch {
            Task { await presenter.showToastError() }
        }
    }

    func getNumberOfRows(in section: OpportunitiesSectionType) -> Int {

        switch section {
        case .search, .filter:
            return 1
        case .opportunitiesLimited:

            if canAccessAllOpportunities || opportunitiesCount == 0 {
                return 0
            }
            return 1
        case .opportunities:

            if opportunitiesCount == 0 && !hasAppliedFilter {
                return pageSizeForPagination
            } else if !canAccessAllOpportunities && opportunitiesCount >= maxNumOfOpportunitiesIfLimited {
                return maxNumOfOpportunitiesIfLimited
            }

            return opportunitiesCount

        case .empty:

            guard opportunitiesCount == 0 && hasAppliedFilter else {
                return 0
            }

            return 1
        case .setUp:
            let hasSetUpSuggestionFilters = OpportunitiesLocalDBHandler.shared.hasSetUpSuggestionFilters()
            return hasSetUpSuggestionFilters ? 0 : 1
        }
    }

    func getOpportunityItem(at row: Int) -> Opportunity? {

        guard row < opportunitiesCount else {
            return nil
        }

        let indexPath = IndexPath(row: row, section: 0)
        return fetchedResultsController.object(at: indexPath)
    }

    func applyFilters(selectedFilter: OpportunityFilter?) {

        self.selectedFilter = selectedFilter

        Task(priority: .userInitiated) {

            do {
                try await self.fetchedResultsController.applyFilters(selectedFilter: selectedFilter)

                await presenter.reloadAllSections()

                guard hasAppliedFilter && opportunitiesCount < pageSizeForPagination else { return }
                refreshOpportunitiesData()
            } catch {
                await presenter.showToastError()
            }
        }
    }

    func clearTypeFilter() {
        selectedFilter?.typeIds.removeAll()
        applyFilters(selectedFilter: selectedFilter)
    }

    func didSelectTypeFilterItem(withId id: String) {

        var newSelectedFilter = selectedFilter ?? OpportunityFilter()
        newSelectedFilter.typeIds.append(id)
        applyFilters(selectedFilter: newSelectedFilter)
    }

    func didSelectLocationFilter(withIds ids: [String]) {

        var newSelectedFilter = selectedFilter ?? OpportunityFilter()
        newSelectedFilter.locationIds = ids
        applyFilters(selectedFilter: newSelectedFilter)
    }

    func didDeselectTypeFilterItem(withId id: String) {
        selectedFilter?.typeIds.removeAll { $0 == id }
        applyFilters(selectedFilter: selectedFilter)
    }

    func updateTypeFilter() {
        Task { await presenter.updateTypeFilterUI(selectedTypeIds: selectedFilter?.typeIds) }
    }

    private func fetchAndCacheOpportunityImageUrls(for opportunities: [Opportunity]?) {

        guard let opportunities = opportunities else { return }

        opportunities.forEach {
            guard $0.imageUrl == nil else { return }
            fetchAndCacheOpportunityImageUrl(urlString: $0.url, opportunity: $0)
        }
    }

    private func fetchAndCacheOpportunityImageUrl(urlString: String, opportunity: Opportunity) {

        guard !opportunity.didFetchImageUrl else { return }

        Task(priority: .userInitiated) {

            guard let imageUrlString = await OpportunitiesNetworkHandler.shared.getOpportunityImageUrl(urlString: urlString, opportunityId: opportunity.id),
                  let imageUrl = URL(string: imageUrlString) else { return }

            imageUrl.fetchAndCacheImage()
        }
    }
}
