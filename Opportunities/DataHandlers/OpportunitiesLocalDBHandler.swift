//
//  OpportunitiesLocalDBHandler.swift
//  Pineapple
//
//  Created by Caoife Davis on 14/03/2023.
//  Copyright © 2023 Pineapple Labs Limited. All rights reserved.
//

import Foundation
import CoreData
import FirebaseFirestore

struct OpportunitiesLocalDBHandler {

    static let shared = OpportunitiesLocalDBHandler()

    private init() {
        // DO NOTHING
    }

    func loadOpportunities(withBackgroundContext backgroundContext: NSManagedObjectContext? = nil) -> [Opportunity] {

        let containerViewContext = backgroundContext ?? AppCoordinator.shared.containerViewContext()

        let request = Opportunity.createFetchRequest()

        let sort = NSSortDescriptor(key: Opportunity.JsonKey.timestamp.rawValue, ascending: false)
        request.sortDescriptors = [sort]

        do {
            return try containerViewContext.fetch(request)
        } catch {
            return [Opportunity]()
        }
    }

    private func loadAllSavedAndViewedOpportunities(withBackgroundContext backgroundContext: NSManagedObjectContext) -> [Opportunity] {

        let request = Opportunity.createFetchRequest()

        let savedPredicate = NSPredicate.searchForObject(usingProperty: Opportunity.JsonKey.isSaved.rawValue,
                                                         withBoolValue: false)
        let viewedPredicate = NSPredicate.searchForObject(usingProperty: Opportunity.JsonKey.isViewed.rawValue,
                                                         withBoolValue: false)
        request.predicate = NSCompoundPredicate(type: .and, subpredicates: [savedPredicate, viewedPredicate])

        do {
            return try backgroundContext.fetch(request)
        } catch {
            return [Opportunity]()
        }
    }

    func loadOpportunity(with id: String, withBackgroundContext backgroundContext: NSManagedObjectContext? = nil) -> Opportunity? {

        let results: [Opportunity]
        let containerViewContext = backgroundContext ?? AppCoordinator.shared.containerViewContext()

        let request = Opportunity.createFetchRequest()
        request.predicate = NSPredicate.searchForObject(usingProperty: Opportunity.JsonKey.id.rawValue, withStringValue: id)

        do {
            results = try containerViewContext.fetch(request)
            guard let opportunity = results.first else { return nil }
            return opportunity
        } catch {
            return nil
        }
    }

    private func loadOpportunities(withIds ids: [String], withBackgroundContext backgroundContext: NSManagedObjectContext) -> [Opportunity] {

        let request = Opportunity.createFetchRequest()

        let predicate = NSPredicate(format: "\(Opportunity.JsonKey.id.rawValue) IN %@", ids)
        request.predicate = predicate

        do {
            return try backgroundContext.fetch(request)
        } catch {
            return [Opportunity]()
        }
    }

    func saveOpportunities(json: [JSON], isSaved: Bool = false, isSuggested: Bool = false) {

        let backgroundContainerViewContext = AppCoordinator.shared.backgroundContainerViewContext()

        let newOpportunityIds = json.compactMap { $0[Opportunity.JsonKey.id.rawValue] as? String }

        backgroundContainerViewContext.perform {

            if isSuggested {
                updateStaleSuggestedOpportunities(withBackgroundContext: backgroundContainerViewContext)
            }

            let localOpportunities = loadOpportunities(withIds: newOpportunityIds, withBackgroundContext: backgroundContainerViewContext)

            for opportunityJson in json {

                guard let id = opportunityJson[Opportunity.JsonKey.id.rawValue] as? String else {
                    continue
                }

                let opportunity: Opportunity
                var didFetchImageUrl = false
                var isSaved = isSaved
                var isViewed = false
                var isSuggested = isSuggested

                if let localOpportunity = localOpportunities.first(where: { $0.id == id}) {

                    opportunity = localOpportunity
                    didFetchImageUrl = opportunity.didFetchImageUrl
                    isViewed = opportunity.isViewed

                    if !isSaved {
                        isSaved = localOpportunity.isSaved
                    }
                    isSuggested = isSuggested ? isSuggested : localOpportunity.isSuggested

                } else {
                    opportunity = Opportunity(context: backgroundContainerViewContext)
                }

                let didSetUpOpportunity = opportunity.setup(using: opportunityJson, imageUrl: opportunity.imageUrl, didFetchImageUrl: didFetchImageUrl,
                                                            isSaved: isSaved,
                                                            isViewed: isViewed,
                                                            isSuggested: isSuggested)

                if !didSetUpOpportunity {
                    backgroundContainerViewContext.delete(opportunity)
                }
            }

            AppCoordinator.shared.saveBackgroundContext(with: backgroundContainerViewContext)

            DispatchQueue.main.async {

                if isSaved {
                    NotificationCenter.default.post(name: NSNotification.Name(savedOpportunitiesLoadedNotification), object: nil)
                }

                if isSuggested {
                    NotificationCenter.default.post(name: NSNotification.Name(suggestedOpportunitiesLoadedNotification), object: nil)
                }

                NotificationCenter.default.post(name: NSNotification.Name(opportunitiesLoadedNotification), object: nil)
            }
        }
    }

    func deleteOpportunities() {

        let backgroundContainerViewContext = AppCoordinator.shared.backgroundContainerViewContext()

        backgroundContainerViewContext.performAndWait {

            let localOpportunities = loadAllSavedAndViewedOpportunities(withBackgroundContext: backgroundContainerViewContext)

            localOpportunities.forEach {
                backgroundContainerViewContext.delete($0)
            }

            AppCoordinator.shared.saveBackgroundContext(with: backgroundContainerViewContext)
        }
    }

    func saveOpportunityTypes(snapshot: QuerySnapshot) {

        let backgroundContainerViewContext = AppCoordinator.shared.backgroundContainerViewContext()

        let newOpportunityTypeIds = snapshot.documents.compactMap { $0.documentID }
        var newOpportunityTypesDocuments = snapshot.documents

        backgroundContainerViewContext.performAndWait {

            let opportunityTypes = loadOpportunityTypes(withBackgroundContext: backgroundContainerViewContext)

            for opportunityType in opportunityTypes {

                if let opportunityDocument = snapshot.documents.first(where: { $0.documentID == opportunityType.id }) {

                    let setUpSucceeded = opportunityType.setup(id: opportunityDocument.documentID, using: opportunityDocument.data(), isSelected: opportunityType.isSelected)

                    newOpportunityTypesDocuments.removeAll(where: { $0.documentID == opportunityType.id })

                    if !setUpSucceeded {
                        backgroundContainerViewContext.delete(opportunityType)
                        continue
                    }
                }
            }

            for opportunityTypesDocument in newOpportunityTypesDocuments {

                let opportunityType = OpportunityType(context: backgroundContainerViewContext)
                let  setUpSucceeded = opportunityType.setup(id: opportunityTypesDocument.documentID, using: opportunityTypesDocument.data())

                if !setUpSucceeded {
                    backgroundContainerViewContext.delete(opportunityType)
                    continue
                }
            }

            AppCoordinator.shared.saveBackgroundContext(with: backgroundContainerViewContext)

            deleteStaleOpportunityTypes(from: newOpportunityTypeIds, withBackgroundContext: backgroundContainerViewContext)

            DispatchQueue.main.async {
                NotificationCenter.default.post(Notification(name: Notification.Name(opportunityTypesLoadedNotification)))
            }
        }
    }
}
