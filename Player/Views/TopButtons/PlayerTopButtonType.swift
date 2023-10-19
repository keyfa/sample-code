//
//  PlayerTopButtonType.swift
//  Pineapple
//
//  Created by Caoife Davis on 16/12/2022.
//  Copyright © 2022 Pineapple Labs Limited. All rights reserved.
//

import Foundation

enum PlayerTopButtonType: Int, CaseIterable {
    case report
    case action
    case share

    var iconImage: UIImage {
        get {
            switch self {
            case .report:
                return #imageLiteral(resourceName: "reportIconWhite")
            case .action:
                return #imageLiteral(resourceName: "iconEllipsisWhite")
            case .share:
                return #imageLiteral(resourceName: "playerShareButtonIcon")
            }
        }
    }

    var iconSize: CGFloat {
        get {
            switch self {
            case .action, .report:
                return 18.0
            case .share:
                return 20.0
            }
        }
    }
}
