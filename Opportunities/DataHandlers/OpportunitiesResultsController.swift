//
//  OpportunitiesResultsController.swift
//  Pineapple
//
//  Created by Caoife Davis on 23/03/2023.
//  Copyright © 2023 Pineapple Labs Limited. All rights reserved.
//

import Foundation
import CoreData

final class OpportunitiesFetchedResultsController: NSFetchedResultsController<Opportunity> {

    var opportunitiesCount: Int {
        get {
            fetchedObjects?.count ?? 0
        }
    }

    var hasAppliedFilter: Bool = false

    let hasViewedPredicate = NSPredicate.searchForObject(usingProperty: Opportunity.JsonKey.isViewed.rawValue,
                                                withBoolValue: true)

    let isSavedPredicate = NSPredicate.searchForObject(usingProperty: Opportunity.JsonKey.isSaved.rawValue,
                                                withBoolValue: true)

    let isSuggestedPredicate = NSPredicate.searchForObject(usingProperty: Opportunity.JsonKey.isSuggested.rawValue,
                                                       withBoolValue: true)

    var isFetchingViewedAndSavedOpportunities: Bool = false

    init(batchSize: Int) {

        let request = Opportunity.createFetchRequest()
        let sort = NSSortDescriptor(key: Opportunity.JsonKey.timestamp.rawValue, ascending: false)
        request.sortDescriptors = [sort]
        request.fetchBatchSize = batchSize

        super.init(fetchRequest: request, managedObjectContext: AppCoordinator.shared.containerViewContext(), sectionNameKeyPath: nil, cacheName: nil)
    }

    func applyFilters(selectedFilter: OpportunityFilter?, searchTerm: String? = nil) async throws {

        func refreshOpportunities(with filter: NSPredicate? = nil) throws {
            fetchRequest.predicate = filter
            try performFetch()
        }

        var predicates = createFilterPredicates(selectedFilter: selectedFilter)

        if isFetchingViewedAndSavedOpportunities {

            let orPredicate = NSCompoundPredicate(type: .or, subpredicates: [hasViewedPredicate, isSavedPredicate])

            predicates.append(orPredicate)
        }

        if let searchTerm = searchTerm {

            let searchTitlePredicate = NSPredicate(format: "\(Opportunity.JsonKey.title.rawValue) LIKE[cd] %@", searchTerm.createWildcardString())

            let searchCompanyPredicate = NSPredicate(format: "\(Opportunity.JsonKey.company.rawValue) LIKE[cd] %@", searchTerm.createWildcardString())

            let orPredicate = NSCompoundPredicate(type: .or, subpredicates: [searchTitlePredicate, searchCompanyPredicate])

            predicates.append(orPredicate)
        }

        guard !predicates.isEmpty else {
            try refreshOpportunities()
            return
        }

        let andPredicate = NSCompoundPredicate(type: .and, subpredicates: predicates)

        try refreshOpportunities(with: andPredicate)
    }

    private func createFilterPredicates(selectedFilter: OpportunityFilter?) -> [NSPredicate] {

        hasAppliedFilter = false

        var predicates = [NSPredicate]()

        guard let selectedFilter = selectedFilter else {
            return predicates
        }

        if selectedFilter.isOpenForHighschoolers {

            SegmentUtil.trackEvent()?.highschoolFilterApplied()

            let openToHighSchoolersPredicate = NSPredicate.searchForObject(usingProperty: Opportunity.JsonKey.forHighSchoolers.rawValue,
                                                                           withBoolValue: selectedFilter.isOpenForHighschoolers)
            predicates.append(openToHighSchoolersPredicate)
        }

        if !selectedFilter.locationIds.isEmpty {

            let locationNames = OpportunitiesLocalDBHandler.shared.loadOpportunityLocations(with: selectedFilter.locationIds).compactMap { $0.title }
            SegmentUtil.trackEvent()?.locationFilterApplied(locationNames: locationNames)

            let locationsPredicate = NSPredicate(format: "(\(Opportunity.JsonKey.location.rawValue) IN %@)", selectedFilter.locationIds)
            predicates.append(locationsPredicate)
        }

        if !selectedFilter.industryIds.isEmpty {

            let industryNames = OpportunitiesLocalDBHandler.shared.loadOpportunityIndustries(with: selectedFilter.industryIds).compactMap { $0.title }
            SegmentUtil.trackEvent()?.industryFilterApplied(industryNames: industryNames)

            let industryPredicate = NSPredicate(format: "(\(Opportunity.JsonKey.industry.rawValue) IN %@)", selectedFilter.industryIds)
            predicates.append(industryPredicate)
        }

        if !selectedFilter.typeIds.isEmpty {

            let typeNames = OpportunitiesLocalDBHandler.shared.loadOpportunityLocations(with: selectedFilter.typeIds).compactMap { $0.title }
            SegmentUtil.trackEvent()?.typeFilterApplied(typeNames: typeNames)

            let typePredicate = NSPredicate(format: "(\(Opportunity.JsonKey.type.rawValue) IN %@)", selectedFilter.typeIds)
            predicates.append(typePredicate)
        }

        hasAppliedFilter = !predicates.isEmpty

        return predicates
    }

    func performFetchAndCacheImages(batchSize: Int) throws {

        try performFetch()

        let fetchedOpportunities: [Opportunity]?

        if opportunitiesCount < batchSize {
            fetchedOpportunities = fetchedObjects
        } else {
            let lastFetchedOpportunities = fetchedObjects?.suffix(batchSize) ?? []
            fetchedOpportunities = Array(lastFetchedOpportunities)
        }

        fetchAndCacheOpportunityImageUrls(for: fetchedOpportunities)
    }

    private func fetchAndCacheOpportunityImageUrls(for opportunities: [Opportunity]?) {

        guard let opportunities = opportunities else { return }

        opportunities.forEach {
            guard $0.imageUrl == nil else { return }
            fetchAndCacheOpportunityImageUrl(urlString: $0.url, opportunity: $0)
        }
    }

    private func fetchAndCacheOpportunityImageUrl(urlString: String, opportunity: Opportunity) {

        guard !opportunity.didFetchImageUrl else {
            return
        }

        Task(priority: .userInitiated) {

            guard let imageUrlString = await OpportunitiesNetworkHandler.shared.getOpportunityImageUrl(urlString: urlString, opportunityId: opportunity.id),
                  let imageUrl = URL(string: imageUrlString) else { return }

            imageUrl.fetchAndCacheImage()
        }
    }

    func setupForSavedOpportunities() {
        fetchRequest.predicate = isSavedPredicate
        try? performFetch()
    }

    func setupForViewedOpportunities() {
        fetchRequest.predicate = hasViewedPredicate
        try? performFetch()
    }

    func setupForSuggestedOpportunities() {
        fetchRequest.predicate = isSuggestedPredicate
        try? performFetch()
    }
}
