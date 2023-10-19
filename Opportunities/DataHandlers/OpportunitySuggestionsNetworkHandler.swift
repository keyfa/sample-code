//
//  OpportunitySuggestionsNetworkHandler.swift
//  Pineapple
//
//  Created by Caoife Davis on 12/04/2023.
//  Copyright © 2023 Pineapple Labs Limited. All rights reserved.
//

import Foundation
import FirebaseFunctions
import FirebaseFirestore

struct OpportunitySuggestionsNetworkHandler {

    static let shared = OpportunitySuggestionsNetworkHandler()

    private enum SuggestionsRequests: String {

        case getSuggestedOpportunities
        case saveOpportunityFilters
        case getSavedOpportunityFilters
        case setOpportunitiesSuggestionsFrequencyInDays

        var requestString: String {
            return "opportunities-" + self.rawValue
        }
    }

    private enum RequestKeys: String {

        case activeUserId
        case typeIds
        case locationIds
        case opportunitiesSuggestionsFrequencyInDays
    }

    private init() {
        // DO NOTHING
    }

    func getSuggestedOpportunities() async throws {

        guard let activeUserId = UserController.shared.activeUser?.userId else {
            throw PineappleError.somethingWentWrong
        }

        let data: JSON = [RequestKeys.activeUserId.rawValue: activeUserId]

        let result = try await Functions.functions()
            .httpsCallable(SuggestionsRequests.getSuggestedOpportunities.requestString)
            .call(data)

        guard let opportunitiesData = result.data as? [JSON] else {
            throw PineappleError.somethingWentWrong
        }

        OpportunitiesLocalDBHandler.shared.saveOpportunities(json: opportunitiesData, isSuggested: true)
    }

    func saveOpportunityFilters(typeIds: [String], locationIds: [String]) async throws {

        guard let activeUserId = UserController.shared.activeUser?.userId else {
            throw PineappleError.somethingWentWrong
        }

        let data: JSON = [RequestKeys.activeUserId.rawValue: activeUserId,
                          RequestKeys.typeIds.rawValue: typeIds,
                          RequestKeys.locationIds.rawValue: locationIds]

        _ = try await Functions.functions()
            .httpsCallable(SuggestionsRequests.saveOpportunityFilters.requestString)
            .call(data)

        OpportunitiesLocalDBHandler.shared.saveOpportunityFilters(typeIds: typeIds, locationIds: locationIds)
    }

    func getSavedOpportunityFilters() async {

        guard let activeUserId = UserController.shared.activeUser?.userId else {
            return
        }

        let data: JSON = [RequestKeys.activeUserId.rawValue: activeUserId]

        let result = try? await Functions.functions()
            .httpsCallable(SuggestionsRequests.getSavedOpportunityFilters.requestString)
            .call(data)

        guard let opportunityFilterData = result?.data as? JSON else {
            return
        }

        OpportunitiesLocalDBHandler.shared.saveOpportunityFilters(json: opportunityFilterData)
    }

    func setOpportunitiesSuggestionsFrequencyInDays(frequency: OpportunitySuggestionsFrequency) async throws {

        guard let activeUserId = UserController.shared.activeUser?.userId else {
            throw PineappleError.somethingWentWrong
        }

        let data: JSON = [RequestKeys.activeUserId.rawValue: activeUserId,
                          RequestKeys.opportunitiesSuggestionsFrequencyInDays.rawValue: frequency.inDays]

        _ = try await Functions.functions()
            .httpsCallable(SuggestionsRequests.setOpportunitiesSuggestionsFrequencyInDays.requestString)
            .call(data)

        UserController.shared.activeUser?.opportunitiesSuggestionsFrequencyInDays = frequency

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name(setupOpportunitySuggestionsCompleted), object: nil)
        }
    }
}
