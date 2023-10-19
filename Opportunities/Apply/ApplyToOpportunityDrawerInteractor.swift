//
//  ApplyToOpportunityDrawerInteractor.swift
//  Pineapple
//
//  Created by Caoife Davis on 29/03/2023.
//  Copyright © 2023 Pineapple Labs Limited. All rights reserved.
//

import Foundation

final class ApplyToOpportunityDrawerInteractor {

    private let presenter: ApplyToOpportunityDrawerPresenter

    init(presenter: ApplyToOpportunityDrawerPresenter) {
        self.presenter = presenter
    }

    func saveOpportunity(opportunityId: String) {

        Task(priority: .userInitiated) {

            await presenter.toggleSpinner(isVisible: true)
            do {
                try await OpportunitiesNetworkHandler.shared.saveOpportunity(opportunityId: opportunityId)
                await presenter.showDidSaveOpportunityToast()
            } catch {
                await presenter.showSavingOpportunityError()
            }
            await presenter.toggleSpinner(isVisible: false)
        }
    }

    func removeOpportunityFromSaved(opportunityId: String) {

        Task(priority: .userInitiated) {

            await presenter.toggleSpinner(isVisible: true)
            do {
                try await OpportunitiesNetworkHandler.shared.removeSavedOpportunity(opportunityId: opportunityId)
            } catch {
                await presenter.showSavingOpportunityError()
            }
            await presenter.toggleSpinner(isVisible: false)
        }
    }
}
