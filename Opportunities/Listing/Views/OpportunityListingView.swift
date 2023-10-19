//
//  OpportunityListingView.swift
//  Pineapple
//
//  Created by Caoife Davis on 14/04/2023.
//  Copyright © 2023 Pineapple Labs Limited. All rights reserved.
//

import Foundation
import Shimmer

final class OpportunityListingView: UIView {

    private let iconSize: CGFloat = 15.0
    private let letterSpacing: CGFloat = -0.39
    private let imageViewHeight: CGFloat = 104.0
    private let imageViewWidth: CGFloat = 119.0
    private let imageBorderOpacity: CGFloat = 0.12
    private let opportunitiesTypeHeight: CGFloat = 36.0
    private let descriptionLineHeight: CGFloat = 18.0
    private let shimmerSpeed: CGFloat = 100.0
    private var horizontalSpacing: CGFloat = CommonConstants.small

    private let dropShadowOpacity: Float = 0.05
    private let dropShadowRadius: CGFloat = 6.0
    private let dropShadowOffset: CGSize = CGSize(width: 0, height: 0)

    private var fetchOpportunityImageUrlTask: Task<(), Never>?

    private lazy var containerTopConstraint: NSLayoutConstraint = {
        return contentContainerView.topAnchor.constraint(equalTo: topAnchor, constant: CommonConstants.tiny)
    }()

    private lazy var containerBottomConstraint: NSLayoutConstraint = {
        return contentContainerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -CommonConstants.tiny)
    }()

    private let backgroundView: BlurView = {

        let view = BlurView(blurEffect: userJourneyBackgroundBlurStyle, blurRadius: userJourneyBackgroundBlurRadius)
        view.backgroundColor = userJourneyBackgroundBlurBackgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var contentContainerView: UIView = {

        let view = UIView()

        view.backgroundColor = .white
        view.addDropShadow(withRadius: dropShadowRadius, offset: dropShadowOffset, opacity: dropShadowOpacity)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var opportunityImageView: UIImageView = {

        let view = UIImageView()

        view.layer.borderColor = UIColor.black.withAlphaComponent(imageBorderOpacity).cgColor
        view.layer.borderWidth = 1
        view.clipsToBounds = true

        view.contentMode = .scaleAspectFill

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var titleLabel: UILabel = {

        let label = UILabel()
        label.font = PAFont.Font16Semibold
        label.textColor = PAColor.descriptionGrey
        label.textAlignment = .left
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)

        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var descriptionLabel: UILabel = {

        let label = UILabel()
        label.font = PAFont.Font18Semibold
        label.textColor = .black
        label.numberOfLines = 2
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.setContentCompressionResistancePriority(.required, for: .vertical)

        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var opportunityTypeView: HorizontalPillsView = {

        let view = HorizontalPillsView()
        view.isSmallCellSize = true
        view.hasGradient = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var timestampLabel: UILabel = {

        let label = UILabel()
        label.font = PAFont.Font13Semibold
        label.textColor = PAColor.descriptionGrey
        label.textAlignment = .right

        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var shimmerView: FBShimmeringView = {

        let shimmerView = FBShimmeringView()
        shimmerView.shimmeringSpeed = shimmerSpeed
        shimmerView.translatesAutoresizingMaskIntoConstraints = false
        return shimmerView
    }()

    private let placeholderImageView: UIImageView = {

        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "opportunitiesLoadingCell")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    init(horizontalSpacing: CGFloat = CommonConstants.small) {
        super.init(frame: .zero)
        self.horizontalSpacing = horizontalSpacing
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        contentContainerView.addCornerRadius(cornerRadius: CommonConstants.small)
        opportunityImageView.addCornerRadius(cornerRadius: CommonConstants.defaultSize)
    }

    func prepareForReuse() {

        titleLabel.text = nil
        opportunityTypeView.removeAll()
        timestampLabel.text = nil
        setupShimmerView(isLoading: false)

        opportunityImageView.sd_cancelCurrentImageLoad()
        fetchOpportunityImageUrlTask?.cancel()
        fetchOpportunityImageUrlTask = nil
    }

    func setupUI(_ opportunity: Opportunity?, isFirstElement: Bool = false, isLastElement: Bool = false) {

        containerTopConstraint.constant = isFirstElement ? CommonConstants.defaultSize : CommonConstants.small
        containerBottomConstraint.constant = isLastElement ? -CommonConstants.defaultSize : -CommonConstants.small

        guard let opportunity = opportunity else {
            setupShimmerView(isLoading: true)
            return
        }

        setupShimmerView(isLoading: false)

        opportunityImageView.image = opportunity.defaultImage
        titleLabel.setTextWithLetterSpacing(string: opportunity.company, letterSpacing: letterSpacing)
        descriptionLabel.setTextWithLetterSpacing(string: opportunity.title, letterSpacing: letterSpacing, lineHeight: descriptionLineHeight)

        let opportunityLocation = OpportunitiesLocalDBHandler.shared.loadOpportunityLocations(with: [opportunity.location]).compactMap { $0.title }
        let opportunityType = OpportunitiesLocalDBHandler.shared.loadOpportunityTypes(with: [opportunity.type]).compactMap { $0.title }
        let opportunityIndustry = OpportunitiesLocalDBHandler.shared.loadOpportunityIndustries(with: [opportunity.industry]).compactMap { $0.title }

        let opportunityTypeStrings = opportunityLocation + opportunityType + opportunityIndustry

        opportunityTypeView.setType(opportunityTypeStrings)

        let prettyTimestamp = TimeIntervalUtil.shared.getPrettyStringForFeedTimestamp(timeInterval: TimeInterval(opportunity.timestamp)) ?? ""
        timestampLabel.setTextWithLetterSpacing(string: prettyTimestamp, letterSpacing: letterSpacing)

        guard let imageUrlString = opportunity.imageUrl else {
            fetchOpportunityImageUrl(urlString: opportunity.url, opportunity: opportunity)
            return
        }

        setOpportunityImage(imageUrlString: imageUrlString, opportunity: opportunity)
    }

    private func setOpportunityImage(imageUrlString: String, opportunity: Opportunity) {

        opportunityImageView.setImage(withUrlString: imageUrlString,
                                      defaultImage: opportunity.defaultImage,
                                      placeholderImage: opportunity.defaultImage) { success in
            guard !success else { return }
            OpportunitiesLocalDBHandler.shared.addImageUrl(for: opportunity.id, imageUrl: nil)
        }
    }

    private func fetchOpportunityImageUrl(urlString: String, opportunity: Opportunity) {

        guard !opportunity.didFetchImageUrl else { return }

        fetchOpportunityImageUrlTask = Task(priority: .userInitiated) {

            guard let imageUrlString = await OpportunitiesNetworkHandler.shared.getOpportunityImageUrl(urlString: urlString, opportunityId: opportunity.id) else { return }

            setOpportunityImage(imageUrlString: imageUrlString, opportunity: opportunity)
        }
    }

    private func setupShimmerView(isLoading: Bool) {

        if isLoading {

            opportunityImageView.isHidden = true
            shimmerView.isHidden = false
            placeholderImageView.isHidden = false
            shimmerView.isShimmering = true
            shimmerView.contentView = placeholderImageView
            bringSubviewToFront(placeholderImageView)
            bringSubviewToFront(shimmerView)

        } else {

            opportunityImageView.isHidden = false
            placeholderImageView.isHidden = true
            shimmerView.isHidden = true
            shimmerView.isShimmering = false
            sendSubviewToBack(shimmerView)
            sendSubviewToBack(placeholderImageView)
        }
    }

    private func setupLayout() {

        backgroundColor = PAColor.tableViewLightGrey

        addSubview(contentContainerView)
        contentContainerView.addSubview(shimmerView)
        contentContainerView.addSubview(placeholderImageView)
        contentContainerView.addSubview(opportunityImageView)
        contentContainerView.addSubview(titleLabel)
        contentContainerView.addSubview(descriptionLabel)
        contentContainerView.addSubview(opportunityTypeView)
        contentContainerView.addSubview(timestampLabel)

        setupConstraints()
    }

    private func setupConstraints() {

        NSLayoutConstraint.activate([

            placeholderImageView.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            placeholderImageView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor),
            placeholderImageView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            placeholderImageView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),

            shimmerView.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            shimmerView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor),
            shimmerView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            shimmerView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),

            containerTopConstraint,
            containerBottomConstraint,
            contentContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalSpacing),
            contentContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalSpacing),

            opportunityImageView.topAnchor.constraint(equalTo: contentContainerView.topAnchor, constant: CommonConstants.large),
            opportunityImageView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor, constant: -CommonConstants.massive),
            opportunityImageView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor, constant: CommonConstants.defaultSize),
            opportunityImageView.heightAnchor.constraint(equalToConstant: imageViewHeight),
            opportunityImageView.widthAnchor.constraint(equalToConstant: imageViewWidth),

            titleLabel.topAnchor.constraint(equalTo: opportunityImageView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: opportunityImageView.trailingAnchor, constant: CommonConstants.small),
            titleLabel.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor, constant: -CommonConstants.defaultSize),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: CommonConstants.small),
            descriptionLabel.leadingAnchor.constraint(equalTo: opportunityImageView.trailingAnchor, constant: CommonConstants.small),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor, constant: -CommonConstants.defaultSize),

            opportunityTypeView.topAnchor.constraint(greaterThanOrEqualTo: descriptionLabel.bottomAnchor, constant: CommonConstants.small),
            opportunityTypeView.bottomAnchor.constraint(equalTo: opportunityImageView.bottomAnchor),
            opportunityTypeView.leadingAnchor.constraint(equalTo: opportunityImageView.trailingAnchor, constant: CommonConstants.small),
            opportunityTypeView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor, constant: -CommonConstants.defaultSize),
            opportunityTypeView.heightAnchor.constraint(equalToConstant: opportunitiesTypeHeight),

            timestampLabel.topAnchor.constraint(equalTo: opportunityImageView.bottomAnchor, constant: CommonConstants.small),
            timestampLabel.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor, constant: -CommonConstants.defaultSize)
        ])
    }

    func addBlurBackground() {

        insertSubview(backgroundView, belowSubview: contentContainerView)

        NSLayoutConstraint.activate([

            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        layoutIfNeeded()
    }

    func removeBlurBackground() {
        backgroundView.removeFromSuperview()
    }
}
