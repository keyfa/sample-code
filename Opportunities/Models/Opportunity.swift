//
//  Opportunity.swift
//  Pineapple
//
//  Created by Caoife Davis on 14/03/2023.
//  Copyright © 2023 Pineapple Labs Limited. All rights reserved.
//

import Foundation
import CoreData

@objc(Opportunity)
class Opportunity: NSManagedObject, SearchableItem {

    enum JsonKey: String {

        case id
        case posterUserId
        case posterName
        case posterAvatarImageUrl
        case company
        case forHighSchoolers
        case location
        case timestamp
        case deadlineTimestamp
        case title
        case type
        case industry
        case url
        case isSaved
        case isViewed
        case isSuggested
    }

    @NSManaged public var id: String
    @NSManaged public var posterUserId: String
    @NSManaged public var posterName: String
    @NSManaged public var posterAvatarImageUrl: String
    @NSManaged public var company: String
    @NSManaged public var forHighSchoolers: Bool
    @NSManaged public var location: String
    @NSManaged public var timestamp: Double
    @NSManaged public var deadlineTimestamp: Double
    @NSManaged public var title: String
    @NSManaged public var type: String
    @NSManaged public var industry: String
    @NSManaged public var url: String
    @NSManaged public var imageUrl: String?
    @NSManaged public var didFetchImageUrl: Bool
    @NSManaged public var isSaved: Bool
    @NSManaged public var isViewed: Bool
    @NSManaged public var isSuggested: Bool

    var toSearchItem: SearchItem {
        get {
            return SearchItem(title: title,
                              type: .opportunity,
                              avatarUrl: imageUrl,
                              itemId: id,
                              descriptionText: company,
                              url: url,
                              defaultImage: defaultImage)
        }
    }

    @nonobjc class func createFetchRequest() -> NSFetchRequest<Opportunity> {
        return NSFetchRequest<Opportunity>(entityName: String(describing: self))
    }

    @discardableResult func setup(using json: JSON, imageUrl: String? = nil, didFetchImageUrl: Bool = false, isSaved: Bool = false, isViewed: Bool = false, isSuggested: Bool = false) -> Bool {

        guard let id = json[JsonKey.id.rawValue] as? String,
              let posterUserId = json[JsonKey.posterUserId.rawValue] as? String,
              let posterName = json[JsonKey.posterName.rawValue] as? String,
              let posterAvatarImageUrl = json[JsonKey.posterAvatarImageUrl.rawValue] as? String,
              let company = json[JsonKey.company.rawValue] as? String,
              let forHighSchoolers = json[JsonKey.forHighSchoolers.rawValue] as? Bool,
              let location = json[JsonKey.location.rawValue] as? String,
              let timestamp = json[JsonKey.timestamp.rawValue] as? Double,
              let title = json[JsonKey.title.rawValue] as? String,
              let type = json[JsonKey.type.rawValue] as? String,
              let industry = json[JsonKey.industry.rawValue] as? String,
              let url = json[JsonKey.url.rawValue] as? String
        else {
            print("Error: Failed to create NSManagedObject")
            return false
        }

        self.id = id
        self.posterUserId = posterUserId
        self.posterName = posterName
        self.posterAvatarImageUrl = posterAvatarImageUrl
        self.company = company
        self.forHighSchoolers = forHighSchoolers
        self.location = location
        self.timestamp = timestamp
        self.title = title
        self.type = type
        self.industry = industry
        self.url = url
        self.imageUrl = imageUrl
        self.didFetchImageUrl = didFetchImageUrl
        self.isSaved = isSaved
        self.isViewed = isViewed
        self.isSuggested = isSuggested

        if let deadlineTimestamp = json[JsonKey.deadlineTimestamp.rawValue] as? Double {
            self.deadlineTimestamp = deadlineTimestamp
        } else {
            self.deadlineTimestamp = -1
        }

        return true
    }
}

extension Opportunity {

    var defaultImage: UIImage {

        let opportunityType = OpportunitiesLocalDBHandler.shared.loadOpportunityTypes(with: [type]).first

        return opportunityType.defaultImage
    }
}
