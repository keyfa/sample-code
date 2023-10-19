//
//  OpportunitiesFilterPresenter.swift
//  Pineapple
//
//  Created by Caoife Davis on 16/03/2023.
//  Copyright © 2023 Pineapple Labs Limited. All rights reserved.
//

import Foundation

@MainActor
struct OpportunitiesFilterPresenter {

    let viewController: OpportunitiesFilterViewController

    func reloadSection(_ section: Int) {
        viewController.collectionView.reloadSectionSafely(section)
    }

    func toggleSpinner(isVisible: Bool) {
        viewController.toggleLoadingSpinner(isVisible: isVisible)
    }

    func setSelectedItems(indexPaths: [IndexPath]) {
        viewController.collectionView.setSelectedItems(indexPaths: indexPaths)
    }

    func deselectAllItems() {
        viewController.collectionView.deselectAllItems(animated: false)
    }
}
