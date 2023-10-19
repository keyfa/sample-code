//
//  PlayerInteractor.swift
//  Pineapple
//
//  Pulled all the logic used for navigating and displaying clips. Posts and user
//  profiles interactions manage the loading of clips for posts/userprofiles and switching between them
//
//  Created by Caoife Davis on 13/12/2022.
//  Copyright © 2022 Pineapple Labs Limited. All rights reserved.
//

import Foundation
import SDWebImage

class PlayerInteractor {

    private(set) var presenter: ProfilePlayerPresenter

    var stillImageTimer: Timer?
    var stillImageTimeRemaining: TimeInterval?
    var startingClip: Clip?
    var clips: [Clip] = []
    var activeClipIndex: Int = 0
    private var storyDidError: Bool = false
    var shouldBeginPlayingStory: Bool = true

    internal let defaultUserName = "User"

    var isPaused = false {
        didSet {
            onPauseStateChange(oldValue: oldValue)
        }
    }

    let playerType: ProfilePlayerType

    init(presenter: ProfilePlayerPresenter, params: ProfilePlayerParmaters) {

        self.presenter = presenter
        self.startingClip = params.startingClip
        self.playerType = params.type
    }

    func startTimer() {

        guard shouldBeginPlayingStory else { return }

        presenter.playVideoClip()

        guard shouldStartTimer() else {
            stillImageTimer = nil
            stillImageTimer?.invalidate()
            return
        }

        isPaused = false

        stillImageTimer?.invalidate()
        stillImageTimer = timer()
    }

    private func shouldStartTimer() -> Bool {

        guard activeClipIndex >= 0,
              activeClipIndex < clips.count,
              clips[activeClipIndex].format == .image else {

            return false
        }

        return true
    }

    func showStoryError() {

        startTimer()
        storyDidError = true
        presenter.showStoryError()

        setBottomSheetData()
    }

    func loadClipAtCurrentIndex() {

        // ~= means activeClipIndex in range 0..<clips.count
        guard 0..<clips.count ~= activeClipIndex else {
            showStoryError()
            return
        }

        stillImageTimer?.invalidate()
        stillImageTimer = nil

        let activeClip = clips[activeClipIndex]

        presenter.displayClip(clip: activeClip)

        guard activeClip.format == .image else {
            return
        }

        stillImageTimer?.invalidate()
        stillImageTimer = self.timer()
    }

    func loadSingleClip() {

        guard let startingClip = startingClip else {
            showStoryError()
            return
        }

        stillImageTimer?.invalidate()
        stillImageTimer = nil

        presenter.displayClip(clip: startingClip)
    }

    func loadNextClip() {

        guard storyDidError == false else {
            storyDidError = false
            loadNextClipGroup()
            return
        }

        isPaused = true
        activeClipIndex += 1

        if activeClipIndex < clips.count {
            loadClipAtCurrentIndex()
        } else {
            loadNextClipGroup()
        }
    }

    func loadPreviousClip() {

        guard storyDidError == false else {
            storyDidError = false
            loadPreviousClipGroup()
            return
        }

        guard storyDidError == false else {
            storyDidError = false
            loadPreviousClipGroup()
            return
        }

        isPaused = true
        activeClipIndex -= 1

        if activeClipIndex < 0 {
            loadPreviousClipGroup()
        } else {
            loadClipAtCurrentIndex()
        }
    }

    func loadNextClipGroup() {
        assertionFailure("Must override")
    }

    func loadPreviousClipGroup() {
        assertionFailure("Must override")
    }

    func setBottomSheetData() {
        assertionFailure("Must override")
    }

    func didBlockUser(userName: String, userId: String) {
        assertionFailure("Must override")
    }

    // Fetches the image using a URL and caches it locally to be used when
    // sd_setImage is ued on an imageview using the same URL
    func downloadClipImages() {

        for clip in clips {
            clip.imageURL?.fetchAndCacheImage()
        }
    }

    private func timer(withInterval interval: TimeInterval = 5) -> Timer {

        return Timer.scheduledTimer(withTimeInterval: interval, repeats: false, block: { [weak self] _ in

            guard let self = self else { return }

            self.stillImageTimer?.invalidate()
            self.stillImageTimer = nil

            self.presenter.shouldHideChaptersView(true)

            guard !self.isPaused else {
                return
            }
            self.loadNextClip()
        })
    }

    private func onPauseStateChange(oldValue: Bool) {

        if isPaused {
            pauseTimer()
        } else if !isPaused && oldValue {
            resumeTimer()
        }
    }

    private func pauseTimer() {

        presenter.pauseClip()

        guard shouldStartTimer() else {
            stillImageTimer?.invalidate()
            stillImageTimer = nil
            return
        }

        guard let timer = stillImageTimer else {
            stillImageTimer?.invalidate()
            stillImageTimer = nil
            return
        }

        let timerRunTime = timer.fireDate
        stillImageTimeRemaining = timerRunTime - Date()
        timer.invalidate()
        stillImageTimer = nil
    }

    private func resumeTimer() {

        presenter.playVideoClip()

        guard shouldStartTimer() else {

            stillImageTimer = nil
            stillImageTimer?.invalidate()
            return
        }

        if let timer = stillImageTimer {
            timer.invalidate()
        }

        guard let timeRemaining = stillImageTimeRemaining else {
            return
        }

        stillImageTimer = timer(withInterval: timeRemaining)
    }

    func didTapConnect(to userProfile: UserProfile, message: String?, isShowingSuggestions: Bool = false, completionHandler: (() -> Void)? = nil) {

        presenter.setButtonState(state: .requested)
        presenter.toggleLoadingSpinnerWithClipStateChange(isVisible: true)
        completionHandler?()

        ActivityFeedNetworkHandler.shared.sendConnectionRequest(to: userProfile, with: message, completionHandler: { [weak self] _, error in

            self?.presenter.toggleLoadingSpinnerWithClipStateChange(isVisible: false)

            guard error == nil else {

                self?.presenter.showToastError()
                self?.presenter.setButtonState(state: .connect)
                self?.startTimer()
                completionHandler?()
                return
            }

            if isShowingSuggestions, let activeUser = UserController.shared.activeUser {

                SegmentUtil.trackEvent()?.connectedWithSuggestion(senderName: activeUser.name,
                                                                  sender: activeUser.userId,
                                                                  receiver: userProfile.userId,
                                                                  receiverName: userProfile.userName)

            }

            ConnectingLocalDBHandler.shared.saveSentConnectionRequest(to: userProfile.userId)

            self?.startTimer()
            completionHandler?()
        })
    }

    func didTapAcceptConnectionRequest(from userProfile: UserProfile, isShowingSuggestions: Bool = false) {

        guard let connectionRequest = ConnectingLocalDBHandler.shared.loadRecievedConnectionRequest(from: userProfile.userId) else {
            presenter.showToastError()
            return
        }

        presenter.toggleLoadingSpinnerWithClipStateChange(isVisible: true)

        ActivityFeedNetworkHandler.shared.handleConnectionRequests(connectionRequest: connectionRequest, shouldAccept: true) { [weak self] _, error in

            self?.presenter.toggleLoadingSpinnerWithClipStateChange(isVisible: false)

            guard error == nil else {
                self?.presenter.showToastError()
                return
            }
            if isShowingSuggestions, let activeUser = UserController.shared.activeUser {
                SegmentUtil.trackEvent()?.connectedWithSuggestion(senderName: activeUser.name,
                                                                  sender: activeUser.userId,
                                                                  receiver: userProfile.userId,
                                                                  receiverName: userProfile.userName)
            }

            let userConnection = UserConnection(context: AppCoordinator.shared.containerViewContext())
            userConnection.setup(using: userProfile)
            AppCoordinator.shared.saveContext()
        }
    }

    func didTapDeleteConnectionRequest(to userProfile: UserProfile, completionHandler: (() -> Void)? = nil) {

        presenter.toggleLoadingSpinnerWithClipStateChange(isVisible: true)

        ActivityFeedNetworkHandler.shared.removeUserConnectionRequest(with: userProfile.userId) { [weak self] _, error in

            self?.presenter.toggleLoadingSpinnerWithClipStateChange(isVisible: false)

            guard error == nil else {
                self?.presenter.showToastError()
                completionHandler?()
                return
            }

            ConnectingLocalDBHandler.shared.deleteSentConnectionRequest(to: userProfile.userId)
            completionHandler?()
        }
    }

    func deleteUserConnection(to userProfile: UserProfile, completionHandler: (() -> Void)? = nil) {
        ConnectingNetworkHandler.shared.deleteConnection(userProfile: userProfile)
        completionHandler?()
    }

    func blockUser(userProfile: UserProfile) {

        let userName = userProfile.userName.isEmptyOrOnlyWhitespace() ? defaultUserName : userProfile.userName

        presenter.toggleLoadingSpinner(isVisible: true)

        UserProfilesNetworkHandler.shared.blockUser(userToBlockId: userProfile.userId) { [weak self] success in

            guard let self = self else { return }

            self.presenter.toggleLoadingSpinner(isVisible: false)

            guard success else {
                self.presenter.showCouldNotBlockError()
                return
            }

            self.didBlockUser(userName: userName, userId: userProfile.userId)
        }
    }
}
