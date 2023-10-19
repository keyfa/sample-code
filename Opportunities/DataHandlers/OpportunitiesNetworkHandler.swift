//
//  OpportunitiesNetworkHandler.swift
//  Pineapple
//
//  Created by Caoife Davis on 14/03/2023.
//  Copyright © 2023 Pineapple Labs Limited. All rights reserved.
//

import Foundation
import FirebaseFunctions
import FirebaseFirestore
import OpenGraph

struct OpportunitiesNetworkHandler {

    static let shared = OpportunitiesNetworkHandler()

    private enum OpportunitiesRequests: String {

        case getOpportunities
        case searchOpportunities
        case getSavedOpportunities
        case saveOpportunity
        case saveOpportunities
        case removeSavedOpportunity
        case getOpportunitiesWithIds

        var requestString: String {
            return "opportunities-" + self.rawValue
        }
    }

    private enum RequestKeys: String {

        case activeUserId
        case allDataBeforeTimestamp
        case dataLimit
        case types
        case locations
        case industries
        case forHighSchoolers
        case searchTerm
        case opportunityId
        case opportunityIds
    }

    private init() {
        // DO NOTHING
    }

    func getOpportunities(allDataBeforeTimestamp: Double,
                          selectedFilter: OpportunityFilter?,
                          pageSize: Int) async throws {

        guard let data = createOpportunityRequestJson(allDataBeforeTimestamp: allDataBeforeTimestamp,
                                                      selectedFilter: selectedFilter,
                                                      pageSize: pageSize) else {
            return
        }

        let result = try await Functions.functions().httpsCallable(OpportunitiesRequests.getOpportunities.requestString).call(data)

        guard let opportunitiesData = result.data as? [JSON] else {
            throw PineappleError.somethingWentWrong
        }

        OpportunitiesLocalDBHandler.shared.saveOpportunities(json: opportunitiesData)
    }

    func searchOpportunities(searchTerm: String,
                             allDataBeforeTimestamp: Double,
                             selectedFilter: OpportunityFilter?,
                             pageSize: Int) async throws {

        guard var data = createOpportunityRequestJson(allDataBeforeTimestamp: allDataBeforeTimestamp,
                                                      selectedFilter: selectedFilter,
                                                      pageSize: pageSize) else {
            return
        }

        data[RequestKeys.searchTerm.rawValue] = searchTerm

        let result = try await Functions.functions().httpsCallable(OpportunitiesRequests.searchOpportunities.requestString).call(data)

        guard let opportunitiesData = result.data as? [JSON] else {
            throw PineappleError.somethingWentWrong
        }

        OpportunitiesLocalDBHandler.shared.saveOpportunities(json: opportunitiesData)
    }

    private func createOpportunityRequestJson(allDataBeforeTimestamp: Double,
                                              selectedFilter: OpportunityFilter?,
                                              pageSize: Int) -> JSON? {

        guard let activeUserId = UserController.shared.activeUser?.userId else {
            return nil
        }

        var data: JSON = [RequestKeys.activeUserId.rawValue: activeUserId,
                          RequestKeys.allDataBeforeTimestamp.rawValue: allDataBeforeTimestamp,
                          RequestKeys.dataLimit.rawValue: pageSize]

        if let typeIds = selectedFilter?.typeIds, !typeIds.isEmpty {
            data[RequestKeys.types.rawValue] = typeIds
        }

        if let locationIds = selectedFilter?.locationIds, !locationIds.isEmpty {
            data[RequestKeys.locations.rawValue] = locationIds
        }

        if let industryIds = selectedFilter?.industryIds, !industryIds.isEmpty {
            data[RequestKeys.industries.rawValue] = industryIds
        }

        if let forHighSchoolers = selectedFilter?.isOpenForHighschoolers, forHighSchoolers == true {
            data[RequestKeys.forHighSchoolers.rawValue] = forHighSchoolers
        }

        return data
    }

    func getOpportunityImageUrl(urlString: String, opportunityId: String) async -> String? {

        guard let url = URL(string: urlString) else {
            OpportunitiesLocalDBHandler.shared.setDidFetchImageUrl(for: opportunityId)
            return nil
        }

        return await withCheckedContinuation { continuation in

            OpenGraph.fetch(url: url) { result in

                OpportunitiesLocalDBHandler.shared.setDidFetchImageUrl(for: opportunityId)

                switch result {
                case .success(let openGraph):
                    OpportunitiesLocalDBHandler.shared.addImageUrl(for: opportunityId, imageUrl: openGraph[.image])
                    continuation.resume(returning: openGraph[.image])
                default:
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    func saveOpportunity(opportunityId: String) async throws {

        guard let activeUserId = UserController.shared.activeUser?.userId else {
            throw PineappleError.somethingWentWrong
        }

        let data: JSON = [RequestKeys.activeUserId.rawValue: activeUserId,
                          RequestKeys.opportunityId.rawValue: opportunityId]

        _ = try await Functions.functions()
            .httpsCallable(OpportunitiesRequests.saveOpportunity.requestString)
            .call(data)

        OpportunitiesLocalDBHandler.shared.saveOpportunityAsSaved(hasSaved: true,
                                                                   for: opportunityId)
    }

    func saveOpportunities(opportunityIds: [String], retry: Bool = true) async throws {

        guard let activeUserId = UserController.shared.activeUser?.userId else {
            throw PineappleError.somethingWentWrong
        }

        for opportunityId in opportunityIds {
            OpportunitiesLocalDBHandler.shared.saveOpportunityAsSaved(hasSaved: true,
                                                                       for: opportunityId)
        }

        let data: JSON = [RequestKeys.activeUserId.rawValue: activeUserId,
                          RequestKeys.opportunityIds.rawValue: opportunityIds]

        do {
            _ = try await Functions.functions()
                .httpsCallable(OpportunitiesRequests.saveOpportunities.requestString)
                .call(data)
        } catch {
            guard retry else { throw PineappleError.couldNotSaveOpportunities }
            try await saveOpportunities(opportunityIds: opportunityIds, retry: false)
        }
    }

    func removeSavedOpportunity(opportunityId: String) async throws {

        guard let activeUserId = UserController.shared.activeUser?.userId else {
            throw PineappleError.somethingWentWrong
        }

        let data: JSON = [RequestKeys.activeUserId.rawValue: activeUserId,
                          RequestKeys.opportunityId.rawValue: opportunityId]

        _ = try await Functions.functions().httpsCallable(OpportunitiesRequests.removeSavedOpportunity.requestString).call(data)

        OpportunitiesLocalDBHandler.shared.saveOpportunityAsSaved(hasSaved: false,
                                                                   for: opportunityId)
    }
}
