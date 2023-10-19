//
//  ApplyToOpportunityDrawerViewController.swift
//  PineappleDevelopment
//
//  Created by Darragh King on 14/03/2023.
//  Copyright © 2023 Pineapple Labs Limited. All rights reserved.
//

import Foundation
import EasyTipView

final class ApplyToOpportunityDrawerViewController: Drawer {

    weak var delegate: ApplyToOpportunityDrawerViewControllerDelegate?

    private let opportunity: Opportunity

    private let drawerCornerRadius: CGFloat = 40.0
    private let titleLetterSpacing: CGFloat = -0.48
    private let toolTipDisplayTime: Int = 1500
    private let toolTipBubbleHorizontalInset: CGFloat = 12

    private let titleText = "opportunity"
    private let saveToolTipTitle = "or save this opportunity for later"

    private var didShowApplyToolTip: Bool = false
    private var didShowSaveToolTip: Bool = false

    override var setDrawerHeightUsingMultiplier: Bool {
        get {
            false
        }
    }

    private lazy var opportunityView: OpportunityView = {

        let opportunityView = OpportunityView(opportunity: opportunity)

        opportunityView.delegate = self

        opportunityView.translatesAutoresizingMaskIntoConstraints = false
        return opportunityView
    }()

    init(opportunity: Opportunity) {
        self.opportunity = opportunity
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.roundCorners([.topLeft, .topRight], radius: drawerCornerRadius)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        HapticController.emit(style: .medium)
        showUserJourneyTipsIfNeeded()
    }

    func setupUI() {

        opportunityView.setupUI()

        drawerPullIndicatorView.isHidden = true
        containerView.backgroundColor = .white

        titleLabel.text = titleText

        setupGestureRecognizers()
        containerView.addSubview(opportunityView)
        setupConstraints()
    }

    func setupGestureRecognizers() {

        let swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeDown))
        swipeDownGestureRecognizer.direction = .down
        containerView.addGestureRecognizer(swipeDownGestureRecognizer)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapAround))
        backgroundView.addGestureRecognizer(tapGestureRecognizer)
    }

    func setupConstraints() {

        NSLayoutConstraint.activate([

            opportunityView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: CommonConstants.large),
            opportunityView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -CommonConstants.huge),
            opportunityView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: CommonConstants.defaultSize),
            opportunityView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -CommonConstants.defaultSize)
        ])
    }

    @objc private func didTapAround() {

        HapticController.emit(style: .light)
        delegate?.didTapAround()
        hideToolTips()
    }

    @objc private func didSwipeDown() {

        HapticController.emit(style: .light)
        delegate?.didSwipeDown()
        hideToolTips()
    }

    @objc func didTapSavedToast() {

        guard AppCoordinator.shared.currentUserJourneyStep != .applyToOpportunity else { return }

        HapticController.emit(style: .light)
        delegate?.goToSavedOpportunities()
        hideToolTips()
    }

    func toggleSaveButton() {
        opportunityView.toggleSaveButton()
    }

    private func showUserJourneyTipsIfNeeded() {
        guard AppCoordinator.shared.currentUserJourneyStep == .applyToOpportunity else { return }
        self.applyButtonUserJourneyWorkItem.perform()
    }
}

extension ApplyToOpportunityDrawerViewController: OpportunityViewDelegate {

    func didTapApply() {
        delegate?.didTapApply()
    }

    func didTapSaveButton() {
        delegate?.didTapSaveOpportunity(opportunityId: opportunity.id)
    }

    func didTapRemoveFromSavedButton() {
        delegate?.removeOpportunityFromSaved(opportunityId: opportunity.id)
    }

    func didTapShareButton() {
        showOpportunityShareSheet(opportunityId: opportunity.id)
    }
}
