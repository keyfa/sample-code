//
//  OpportunityEmptyState.swift
//  Pineapple
//
//  Created by Caoife Davis on 06/04/2023.
//  Copyright © 2023 Pineapple Labs Limited. All rights reserved.
//

import Foundation

enum OpportunityEmptyState {

    case all
    case viewed
    case saved

    var title: String {

        switch self {
        case .all:
            return "we couldn’t find any\nopportunities"
        case .viewed:
            return "you haven’t viewed any\nopportunities yet"
        case .saved:
            return "you haven’t saved any\nopportunities yet"
        }
    }

    var buttonTitle: String {

        switch self {
        case .all:
            return "see all opportunties"
        case .viewed, .saved:
            return "browse opportunties"
        }
    }
}
