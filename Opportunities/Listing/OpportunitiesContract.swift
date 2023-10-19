//
//  OpportunitiesContract.swift
//  Pineapple
//
//  Created by Caoife Davis on 09/03/2023.
//  Copyright © 2023 Pineapple Labs Limited. All rights reserved.
//

import Foundation

protocol OpportunitiesViewControllerDelegate: AnyObject {

    func refreshData()
    func getSectionCount() -> Int
    func getNumberOfRows(in section: Int) -> Int
    func getSectionType(for section: Int) -> OpportunitiesSectionType?
    func getOpportunityItem(at row: Int) -> Opportunity?
    func loadMoreOpportunities()
    func updateTypeFilter()
    func isOpenForHighschoolersFilterApplied() -> Bool
    func getLocationIdsFilter() -> [String]
    func getSelectedFilter() -> OpportunityFilter?

    func clearTypeFilter()
    func clearAllFilters()
    func didSelectTypeFilterItem(withId id: String)
    func didDeselectTypeFilterItem(withId id: String)

    func goToConversations()
    func didTapActivityFeedButton()
    func didTapSavedButton()

    func didTapOpportunity(opportunity: Opportunity)
    func goToOpportunityFilters()
    func openLocationsFilterDrawer()
    func didTapSearch()
    func didTapSuggestionsBanner()
    func viewDidAppear()
}

protocol OpportunitiesLimitedDelegate: AnyObject {
    func canAccessOpportunities()
}

enum OpportunitiesSectionType: Int, CaseIterable {

    case search
    case filter
    case setUp
    case opportunities
    case opportunitiesLimited
    case empty
}
