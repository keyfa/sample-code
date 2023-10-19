//
//  ApplyToOpportunityDrawerPresenter.swift
//  Pineapple
//
//  Created by Caoife Davis on 29/03/2023.
//  Copyright © 2023 Pineapple Labs Limited. All rights reserved.
//

import Foundation

@MainActor
struct ApplyToOpportunityDrawerPresenter {

    let viewController: ApplyToOpportunityDrawerViewController

    static let savedOpportunityTitle = "Saved! Tap to view your saves"

    func showDidSaveOpportunityToast() {

        viewController.showToastView(on: viewController.view,
                                     with: ApplyToOpportunityDrawerPresenter.savedOpportunityTitle,
                                     shouldDisplayCheckMark: false,
                                     decorationImage: #imageLiteral(resourceName: "jamArchivedIcon"),
                                     toastPosition: .top,
                                     onTapSelector: #selector(viewController.didTapSavedToast),
                                     target: viewController)
    }

    func toggleSpinner(isVisible: Bool) {
        viewController.toggleLoadingSpinner(isVisible: isVisible)
    }

    func showSavingOpportunityError() {

        viewController.toggleSaveButton()
        viewController.showToastView(on: viewController.view,
                                     with: PineappleError.somethingWentWrong.displayedError,
                                     shouldDisplayCheckMark: false,
                                     toastPosition: .top)
    }
}
