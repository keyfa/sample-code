//
//  OpportunitiesFilterDrawerContract.swift
//  Pineapple
//
//  Created by Caoife Davis on 16/03/2023.
//  Copyright © 2023 Pineapple Labs Limited. All rights reserved.
//

import Foundation

protocol OpportunitiesFilterViewControllerDelegate: AnyObject {

    func getItemCount(section: Int) -> Int
    func getNumberOfSections() -> Int
    func getSectionTitle(_ section: Int) -> String?
    func getSectionType(section: Int) -> OpportunityFilterSections?
    func getItemTitle(at indexPath: IndexPath) -> String?
    func viewWillAppear()

    func backButtonTapped()
    func showLocationSelection()
    func clearSelection()
}

protocol OpportunitiesFilterDelegate: AnyObject {
    func didAddFilters(selectedFilter: OpportunityFilter?)
}

enum OpportunityFilterSections: Int, CaseIterable {

    case location
    case openToHighSchoolers
    case type
    case industry

    var sectionTitle: String {

        switch self {

        case .location:
            return "location"
        case .openToHighSchoolers:
            return "open to high school students"
        case .type:
            return "opportunity type"
        case .industry:
            return "industry"
        }
    }

    var defaultFilterTitle: String? {

        switch self {

        case .location:
            return "All locations"
        case .openToHighSchoolers:
            return "Yes"
        default:
            return nil
        }
    }

    var iconImage: UIImage? {

        switch self {

        case .location:
            return #imageLiteral(resourceName: "locationIconBlue")
        case .openToHighSchoolers:
            return #imageLiteral(resourceName: "iconCheckGrey")
        case .industry:
            return #imageLiteral(resourceName: "industryIconGrey")
        default:
            return nil
        }
    }

    func getAppliedFilterTitle(for ids: [String] = []) -> String? {

        switch self {

        case .location:

            guard !ids.isEmpty else {
                return defaultFilterTitle
            }
            return OpportunitiesUtil.shared.getOpportunityLocationsString(with: ids)
        case .openToHighSchoolers:
            return "high school"
        case .type:
            return nil
        case .industry:
            return OpportunitiesUtil.shared.getOpportunityIndustriesString(with: ids)
        }
    }
}
