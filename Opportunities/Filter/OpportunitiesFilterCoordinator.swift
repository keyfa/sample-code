//
//  OpportunitiesFilterCoordinator.swift
//  Pineapple
//
//  Created by Caoife Davis on 16/03/2023.
//  Copyright © 2023 Pineapple Labs Limited. All rights reserved.
//

import Foundation

final class OpportunitiesFilterCoordinator: Coordinator {

    weak var delegate: OpportunitiesFilterDelegate?

    private var childCoordinators = [Coordinator]()
    var completionHandler: CoordinatorCompletionHandler?
    var navigationController: UINavigationController

    let viewController: OpportunitiesFilterViewController
    let interactor: OpportunitiesFilterInteractor
    let presenter: OpportunitiesFilterPresenter

    init(navigationController: UINavigationController, selectedFilter: OpportunityFilter?) {

        self.navigationController = navigationController
        viewController = OpportunitiesFilterViewController()
        presenter = OpportunitiesFilterPresenter(viewController: viewController)
        interactor = OpportunitiesFilterInteractor(presenter: presenter, selectedFilter: selectedFilter)

        viewController.delegate = self
    }

    func start(completionHandler: CoordinatorCompletionHandler?) {
        self.completionHandler = completionHandler
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension OpportunitiesFilterCoordinator: OpportunitiesFilterViewControllerDelegate {

    func showLocationSelection() {

        let coordinator = OpportunityLocationDrawerCoordinator(navigationController: navigationController, selectedOpportunityLocationIds: interactor.selectedLocationIds)

        coordinator.delegate = self

        coordinator.start { [weak self] in
            self?.childCoordinators.removeAll { $0 is OpportunityLocationDrawerCoordinator}
        }

        childCoordinators.append(coordinator)
    }

    func getSectionTitle(_ section: Int) -> String? {
        return getSectionType(section: section)?.sectionTitle
    }

    func getItemCount(section: Int) -> Int {
        return interactor.getNumberOfItems(in: section)
    }

    func getNumberOfSections() -> Int {
        return OpportunityFilterSections.allCases.count
    }

    func getSectionType(section: Int) -> OpportunityFilterSections? {
        return OpportunityFilterSections(rawValue: section)
    }

    func getItemTitle(at indexPath: IndexPath) -> String? {
        return interactor.getItemTitle(at: indexPath)
    }

    func backButtonTapped() {

        delegate?.didAddFilters(selectedFilter: interactor.getSelectedFilter())
        navigationController.popViewController(animated: true)
        completionHandler?()

    }

    func viewWillAppear() {
        interactor.setInitiallySelectedItems()
    }

    func clearSelection() {
        interactor.clearSelection()
    }
}

extension OpportunitiesFilterCoordinator: OpportunityLocationDrawerDelegate {

    func didTapSaveLocations(locationIds: [String]) {
        interactor.selectedLocationIds = locationIds
        Task { await presenter.reloadSection(OpportunityFilterSections.location.rawValue) }
    }
}
