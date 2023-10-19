//
//  OpportunitiesPresenter.swift
//  Pineapple
//
//  Created by Caoife Davis on 09/03/2023.
//  Copyright © 2023 Pineapple Labs Limited. All rights reserved.
//

import Foundation

@MainActor
struct OpportunitiesPresenter {

    let viewController: OpportunitiesViewController

    func reloadSection(_ section: Int) {

        viewController.tableView.refreshControl?.endRefreshing()

        UIView.performWithoutAnimation {
            viewController.tableView.reloadRowsInSection(section)
        }
    }

    func reloadSections(_ sections: [Int]) {

        viewController.tableView.refreshControl?.endRefreshing()

        UIView.performWithoutAnimation {
            viewController.tableView.reloadRowsInSections(sections)
        }
    }

    func reloadOpportunitySections() {

        let sections = [OpportunitiesSectionType.opportunities.rawValue,
                        OpportunitiesSectionType.empty.rawValue,
                        OpportunitiesSectionType.opportunitiesLimited.rawValue,
                        OpportunitiesSectionType.setUp.rawValue]

        reloadSections(sections)
        viewController.showUserJourneyOpportunityListingUIIfNeeded()
    }

    func reloadAllSections() {

        let sections: [Int] = OpportunitiesSectionType.allCases.compactMap {

            guard $0 != .search else {
                return nil
            }

            return $0.rawValue
        }

        reloadSections(sections)
    }

    func toggleSpinner(isVisible: Bool) {
        viewController.toggleLoadingSpinner(isVisible: isVisible)
    }

    func showToastError() {
        viewController.tableView.refreshControl?.endRefreshing()
        viewController.showToastError()
    }

    func scrollToTop() {
        viewController.tableView.animateScrollToTop(completionHandler: nil)
    }

    func updateTypeFilterUI(selectedTypeIds: [String]?) {
        viewController.oppotunityTypeFilterDelegate?.setSelectedFilterItems(selectedTypeIds: selectedTypeIds ?? [])
    }
}
