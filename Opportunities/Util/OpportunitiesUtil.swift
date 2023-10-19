//
//  OpportunitiesUtil.swift
//  Pineapple
//
//  Created by Caoife Davis on 21/03/2023.
//  Copyright © 2023 Pineapple Labs Limited. All rights reserved.
//

import Foundation

struct OpportunitiesUtil {

    static let shared = OpportunitiesUtil()

    func getOpportunityLocationsString(with selectedIds: [String]) -> String? {

        let selectedLocations = OpportunitiesLocalDBHandler.shared.loadOpportunityLocations(with: selectedIds)

        let locationTitles = selectedLocations.map { $0.title }
        return getAppliedFilterString(with: locationTitles)
    }

    func getOpportunityIndustriesString(with selectedIds: [String]) -> String? {

        let selectedIndustries = OpportunitiesLocalDBHandler.shared.loadOpportunityIndustries(with: selectedIds)

        let industryTitles = selectedIndustries.map { $0.title }
        return getAppliedFilterString(with: industryTitles)
    }

    private func getAppliedFilterString(with filterTitles: [String]) -> String? {

        guard let firstfilterTitle = filterTitles.first else {
            return nil
        }

        guard filterTitles.count > 1 else {
            return firstfilterTitle
        }

        return firstfilterTitle + " & \(filterTitles.count - 1) more"
    }
}
