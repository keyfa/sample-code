//
//  ApplyToOpportunityDrawerCoordinator.swift
//  PineappleDevelopment
//
//  Created by Darragh King on 14/03/2023.
//  Copyright © 2023 Pineapple Labs Limited. All rights reserved.
//

import Foundation

final class ApplyToOpportunityDrawerCoordinator: Coordinator {

    weak var delegate: ApplyToOpportunityDrawerDelegate?

    var navigationController: UINavigationController

    private let opportunity: Opportunity

    private var childCoordinators = [Coordinator]()
    private let viewController: ApplyToOpportunityDrawerViewController
    private let interactor: ApplyToOpportunityDrawerInteractor
    private let presenter: ApplyToOpportunityDrawerPresenter

    var completionHandler: CoordinatorCompletionHandler?

    init(navigationController: UINavigationController, opportunity: Opportunity) {

        self.navigationController = navigationController
        self.opportunity = opportunity

        viewController = ApplyToOpportunityDrawerViewController(opportunity: opportunity)
        presenter = ApplyToOpportunityDrawerPresenter(viewController: viewController)
        interactor = ApplyToOpportunityDrawerInteractor(presenter: presenter)

        viewController.modalPresentationStyle = .overFullScreen
        viewController.delegate = self

    }

    func start(completionHandler: CoordinatorCompletionHandler?) {
        self.completionHandler = completionHandler
        navigationController.present(viewController, animated: false)
    }

    func dismiss(dismissCompletionHandler: (() -> Void)? = nil) {

        viewController.prepareUIForDismiss()

        navigationController.dismiss(animated: true) { [weak self] in
            dismissCompletionHandler?()
            self?.completionHandler?()
        }
    }
}

extension ApplyToOpportunityDrawerCoordinator: ApplyToOpportunityDrawerViewControllerDelegate {

    func removeOpportunityFromSaved(opportunityId: String) {
        interactor.removeOpportunityFromSaved(opportunityId: opportunityId)
    }

    func didTapSaveOpportunity(opportunityId: String) {
        interactor.saveOpportunity(opportunityId: opportunityId)
    }

    func didTapApply() {

        SegmentUtil.trackEvent()?.tappedApplyToOpportunityButton(opportunityId: opportunity.id)

        dismiss { [weak self] in

            guard let self = self else { return }

            self.delegate?.goToOpportunity(stringUrl: self.opportunity.url,
                                           opportunityId: self.opportunity.id)
        }
    }

    func didTapAround() {
        updateUserJourneyIfNeededAndDismiss()
    }

    func didSwipeDown() {
        updateUserJourneyIfNeededAndDismiss()
    }

    private func updateUserJourneyIfNeededAndDismiss() {

        if AppCoordinator.shared.currentUserJourneyStep == .applyToOpportunity {
            AppCoordinator.shared.currentUserJourneyStep = .exploreNetworking
        }
        dismiss()
    }

    func goToSavedOpportunities() {

        dismiss { [weak self] in
            self?.delegate?.goToSavedOpportunities()
        }
    }
}
