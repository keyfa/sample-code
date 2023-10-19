//
//  PlayerBottomSheetViewController.swift
//  Pineapple
//
//  This view controller has the functions used for the interactions with the bottom
//  sheet on the player, children of this will manage the UI and some logic
//
//  Created by Caoife Davis on 13/12/2022.
//  Copyright © 2022 Pineapple Labs Limited. All rights reserved.
//

import Foundation

enum PanDirection {
    case up
    case down
}

enum PlayerSheetPosition {
    case expanded
    case peek
}

class PlayerBottomSheetViewController: UIViewController {

    weak var delegate: ProfileCardsBottomSheetDelegate?

    static let downAnimationDuration: CGFloat = 0.25
    static let upAnimationDuration: CGFloat = 0.33

    let peekHeightConstant: CGFloat = 60
    let minTopDistance: CGFloat = 200
    private(set) lazy var peekHeightValue: CGFloat = peekHeightConstant
    private(set) lazy var fullHeight: CGFloat = minTopDistance
    private(set) lazy var peekHeight: CGFloat = UIScreen.main.bounds.height - peekHeightValue

    var shouldSetInitialPosition: Bool = true
    var isInitialHeightFullHeight: Bool = true
    private(set) var shouldKeepExpanded: Bool = false
    private var shouldKeepPeeked: Bool = false

    private(set) var sheetPosition: PlayerSheetPosition = .peek

    var viewVisibleAtPeekHeight: UIView? {
        didSet {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedCardSheet))
            tapGesture.delegate = self
            tapGesture.cancelsTouchesInView = false
            viewVisibleAtPeekHeight?.addGestureRecognizer(tapGesture)
        }
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        setupUI()
        addGestures()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if shouldSetInitialPosition, viewVisibleAtPeekHeight != nil {

            shouldSetInitialPosition = false
            isInitialHeightFullHeight ? setViewToFullHeight() : setViewToInitialPosition()
            isInitialHeightFullHeight = false
        } else if sheetPosition == .expanded {
            setViewToFullHeight()
        }
    }

    func setupUI() {
        view.backgroundColor = .clear
        view.clipsToBounds = false
    }

    func addGestures() {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture))
        view.addGestureRecognizer(gesture)
    }

    func setViewToInitialPosition() {

        sheetPosition = .peek

        UIView.animate(withDuration: ProfileCardsBottomSheetViewController.upAnimationDuration, animations: { [weak self] in

            guard let self = self else { return }

            self.delegate?.didCloseBottomSheet()
            self.view.frame = CGRect(x: 0, y: self.peekHeight, width: self.view.frame.width, height: self.view.frame.height - self.minTopDistance)
        })
    }

    // Sets the height of the bottom sheet as you user pans on the view as if they are dragging the UI
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {

        guard shouldKeepExpanded == false else { return }

        let translation = recognizer.translation(in: view)
        let minYPositionInView = view.frame.minY

        if isTranslationIsWithinFullAndPartialHeight(y: minYPositionInView, translationY: translation.y) {
            view.frame = CGRect(x: 0, y: minYPositionInView + translation.y, width: view.frame.width, height: view.frame.height)
            recognizer.setTranslation(CGPoint.zero, in: view)
        }

        let direction = recognizer.velocity(in: view).y
        if getDirection(direction) == .up {
            updateUIOnPositionChange(position: .peek)
        }

        // Sets the end view height once the gesture is finished
        if recognizer.state == .ended ||
            recognizer.state == .cancelled ||
            recognizer.state == .failed {

            guard shouldKeepPeeked == false else {
                setViewToPartialHeight()
                return
            }

            if getDirection(direction) == .down {
                setViewToPartialHeight()
            } else {
                setViewToFullHeight()
            }
        }
    }

    @objc func tappedCardSheet() {

        guard sheetPosition == .peek else {
            return
        }
        setViewToFullHeight()
    }

    func close() {
        setViewToPartialHeight()
    }

    func setViewToPartialHeight() {

        updateUIOnPositionChange(position: .peek)
        sheetPosition = .peek

        UIView.animate(withDuration: ProfileCardsBottomSheetViewController.downAnimationDuration, delay: 0.0, options: [.allowUserInteraction], animations: { [weak self] in

            guard let self = self else { return }

            self.updateScrollViewOffsetForPartialHeight()
            self.delegate?.didCloseBottomSheet()
            self.view.frame = CGRect(x: 0, y: self.peekHeight, width: self.view.frame.width, height: self.view.frame.height)
        })
    }

    func setViewToFullHeight() {

        updateUIOnPositionChange(position: .expanded)

        sheetPosition = .expanded
        UIView.animate(withDuration: ProfileCardsBottomSheetViewController.upAnimationDuration, delay: 0.0, options: [.allowUserInteraction], animations: { [weak self] in

            guard let self = self else { return }

            if !self.shouldKeepExpanded {
                self.delegate?.didExpandBottomSheet()
            }
            self.view.frame = CGRect(x: 0, y: self.fullHeight, width: self.view.frame.width, height: self.view.frame.height)
        })
    }

    func getDirection(_ yOffset: CGFloat) -> PanDirection {

        switch yOffset {
        case _ where yOffset >= 0:
            return .down
        default:
            return .up
        }
    }

    func isTranslationIsWithinFullAndPartialHeight(y: CGFloat, translationY: CGFloat) -> Bool {
        return (y + translationY >= fullHeight) && (y + translationY <= peekHeight)
    }

    func isUserProfileCardAtFullHeight(y: CGFloat, translationY: CGFloat) -> Bool {
        return y + translationY == fullHeight
    }

    func shouldKeepExpanded(_ expanded: Bool = true) {

        shouldKeepExpanded = expanded

        guard expanded else {
            return
        }

        setViewToFullHeight()
    }

    func changeUserCardAnimation() {

        sheetPosition = .peek
        updateUIOnPositionChange(position: .peek)

        UIView.animate(withDuration: ProfileCardsBottomSheetViewController.downAnimationDuration, animations: { [weak self] in

            guard let self = self else { return }

            self.view.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: self.view.frame.width, height: self.view.frame.height)
            self.refreshBottomSheetData()
        }, completion: {_ in
            UIView.animate(withDuration: ProfileCardsBottomSheetViewController.upAnimationDuration, animations: { [weak self] in

                guard let self = self else { return }

                self.view.frame = CGRect(x: 0, y: self.shouldKeepExpanded ? self.fullHeight : self.peekHeight, width: self.view.frame.width, height: self.view.frame.height)
            })
        })
    }

    func updateUIOnPositionChange(position: PlayerSheetPosition) {
        assertionFailure("Must override")
    }

    func refreshBottomSheetData() {
        assertionFailure("Must override")
    }

    func updateScrollViewOffsetForPartialHeight() {
        // DO NOTHING
    }
}

extension PlayerBottomSheetViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {

        guard touch.view?.isKind(of: UIControl.self) == true || touch.view?.isKind(of: UserAvatarsView.self) == true else {
            return true
        }
        return false
    }
}
