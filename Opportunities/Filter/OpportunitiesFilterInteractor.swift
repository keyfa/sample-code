//
//  OpportunitiesFilterInteractor.swift
//  Pineapple
//
//  Created by Caoife Davis on 16/03/2023.
//  Copyright © 2023 Pineapple Labs Limited. All rights reserved.
//

import Foundation

final class OpportunitiesFilterInteractor {

    private let presenter: OpportunitiesFilterPresenter

    private var opportunityTypesList = OpportunitiesLocalDBHandler.shared.loadOpportunityTypes()
    private var industriesList = OpportunitiesLocalDBHandler.shared.loadOpportunityIndustries()
    private var locationsList = OpportunitiesLocalDBHandler.shared.loadOpportunityLocations()

    var selectedLocationIds: [String]?
    private var initialSelectedIndexes: [IndexPath]? = [IndexPath]()

    private let numberOfLoadingCells: Int = 9

    init(presenter: OpportunitiesFilterPresenter, selectedFilter: OpportunityFilter?) {

        self.presenter = presenter

        setupObservers()
        createSelectedIndexes(filter: selectedFilter)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupObservers() {

        if opportunityTypesList.isEmpty {

            NotificationCenter.default.addObserver(self, selector: #selector(reloadOpportunityTypes),
                                                   name: NSNotification.Name(opportunityTypesLoadedNotification),
                                                   object: nil)
            Task(priority: .high) { await OpportunitiesNetworkHandler.shared.getOpportunityTypes() }
        }

        if industriesList.isEmpty {

            NotificationCenter.default.addObserver(self, selector: #selector(reloadOpportunityIndustries),
                                                   name: NSNotification.Name(opportunityIndustriesLoadedNotification),
                                                   object: nil)
            Task(priority: .high) { await OpportunitiesNetworkHandler.shared.getOpportunityIndustries() }
        }
    }

    private func createSelectedIndexes(filter: OpportunityFilter?) {

        guard var initialSelectedIndexes = initialSelectedIndexes,
              let filter = filter else { return }

        selectedLocationIds = filter.locationIds

        if filter.isOpenForHighschoolers {
            let selectedOpenForHighschoolIndex = IndexPath(row: 0, section: OpportunityFilterSections.openToHighSchoolers.rawValue)
            initialSelectedIndexes.append(selectedOpenForHighschoolIndex)
        }

        initialSelectedIndexes += filter.typeIds.compactMap { typeId in

            guard let index = opportunityTypesList.firstIndex( where: { typeId == $0.id }) else {
                return nil
            }
            return IndexPath(row: index, section: OpportunityFilterSections.type.rawValue)
        }

        initialSelectedIndexes += filter.industryIds.compactMap { industryId in

            guard let index = industriesList.firstIndex( where: { industryId == $0.id }) else {
                return nil
            }
            return IndexPath(row: index, section: OpportunityFilterSections.industry.rawValue)
        }

        self.initialSelectedIndexes = initialSelectedIndexes
    }

    func setInitiallySelectedItems() {

        guard let initialSelectedIndexes = initialSelectedIndexes else { return }
        Task { await presenter.setSelectedItems(indexPaths: initialSelectedIndexes) }
        self.initialSelectedIndexes = nil
    }

    func getNumberOfItems(in section: Int) -> Int {

        guard let sectionType = OpportunityFilterSections(rawValue: section) else {
            return 0
        }

        switch sectionType {
        case .location, .openToHighSchoolers:
            return 1
        case .type:
            return opportunityTypesList.isEmpty ? numberOfLoadingCells : opportunityTypesList.count
        case .industry:
            return industriesList.isEmpty ? numberOfLoadingCells : industriesList.count
        }
    }

    func getItemTitle(at indexPath: IndexPath) -> String? {

        guard let section = OpportunityFilterSections(rawValue: indexPath.section) else {
            return nil
        }

        switch section {
        case .location:

            guard let selectedLocationIds = selectedLocationIds,
                  let formatedString = OpportunitiesUtil.shared.getOpportunityLocationsString(with: selectedLocationIds)  else {
                return section.defaultFilterTitle
            }

            return formatedString
        case .openToHighSchoolers:
            return section.defaultFilterTitle
        case .type:
            return opportunityTypesList.getItemSafely(indexPath.row)?.title
        case .industry:
            return industriesList.getItemSafely(indexPath.row)?.title
        }
    }

    private func getSelectedOpportunityTypeIds() -> [String] {

        guard let selectedItems = presenter.viewController.collectionView.indexPathsForSelectedItems else {
            return []
        }

        let selectedOpportunityItemIndexes = selectedItems.filter { $0.section == OpportunityFilterSections.type.rawValue }
        let selectedOpportunityItemIds = selectedOpportunityItemIndexes.compactMap { opportunityTypesList.getItemSafely($0.row)?.id }
        return selectedOpportunityItemIds
    }

    private func getSelectedIndustryIds() -> [String] {

        guard let selectedItems = presenter.viewController.collectionView.indexPathsForSelectedItems else {
            return []
        }

        let selectedOpportunityItemIndexes = selectedItems.filter { $0.section == OpportunityFilterSections.industry.rawValue }
        let selectedIndustryItemIds = selectedOpportunityItemIndexes.compactMap { industriesList.getItemSafely($0.row)?.id }
        return selectedIndustryItemIds
    }

    private func isOpenForHighschoolers() -> Bool {

        guard let selectedItems = presenter.viewController.collectionView.indexPathsForSelectedItems else {
            return false
        }

        let selectedHighschoolersIndexes = selectedItems.filter { $0.section == OpportunityFilterSections.openToHighSchoolers.rawValue }
        let isOpenForHighschoolers = !selectedHighschoolersIndexes.isEmpty
        return isOpenForHighschoolers
    }

    func getSelectedFilter() -> OpportunityFilter {

        OpportunityFilter(locationIds: selectedLocationIds ?? [],
                          isOpenForHighschoolers: isOpenForHighschoolers(),
                          typeIds: getSelectedOpportunityTypeIds(),
                          industryIds: getSelectedIndustryIds())
    }

    @objc private func reloadOpportunityTypes() {

        opportunityTypesList = OpportunitiesLocalDBHandler.shared.loadOpportunityTypes()
        Task { await presenter.reloadSection(OpportunityFilterSections.type.rawValue) }

        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name(opportunityTypesLoadedNotification),
                                                  object: nil)
    }

    @objc private func reloadOpportunityIndustries() {

        industriesList = OpportunitiesLocalDBHandler.shared.loadOpportunityIndustries()
        Task { await presenter.reloadSection(OpportunityFilterSections.industry.rawValue) }

        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name(opportunityIndustriesLoadedNotification),
                                                  object: nil)
    }

    func clearSelection() {

        selectedLocationIds = []
        Task {
            await presenter.reloadSection(OpportunityFilterSections.location.rawValue)
            await presenter.deselectAllItems()
        }
    }
}
