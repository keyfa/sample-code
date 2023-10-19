//
//  ApplyToOpportunityDrawerContract.swift
//  PineappleDevelopment
//
//  Created by Darragh King on 14/03/2023.
//  Copyright © 2023 Pineapple Labs Limited. All rights reserved.
//

import Foundation

protocol ApplyToOpportunityDrawerViewControllerDelegate: DrawerDelegate {

    func didTapApply()
    func didTapSaveOpportunity(opportunityId: String)
    func removeOpportunityFromSaved(opportunityId: String)
    func goToSavedOpportunities()
}

protocol ApplyToOpportunityDrawerDelegate: AnyObject {
    func goToOpportunity(stringUrl: String, opportunityId: String)
    func goToSavedOpportunities()
}
