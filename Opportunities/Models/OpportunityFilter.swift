//
//  OpportunityFilter.swift
//  Pineapple
//
//  Created by Caoife Davis on 17/03/2023.
//  Copyright © 2023 Pineapple Labs Limited. All rights reserved.
//

import Foundation

struct OpportunityFilter {

    var locationIds: [String]
    let isOpenForHighschoolers: Bool
    var typeIds: [String]
    let industryIds: [String]

    init(locationIds: [String] = [], isOpenForHighschoolers: Bool = false, typeIds: [String] = [], industryIds: [String] = []) {

        self.locationIds = locationIds
        self.isOpenForHighschoolers = isOpenForHighschoolers
        self.typeIds = typeIds
        self.industryIds = industryIds
    }

    var hasAppliedFilters: Bool {
        get {
            let areAllFiltersEmpty = !isOpenForHighschoolers
            && locationIds.isEmpty
            && industryIds.isEmpty
            && typeIds.isEmpty
            return !areAllFiltersEmpty
        }
    }
}
