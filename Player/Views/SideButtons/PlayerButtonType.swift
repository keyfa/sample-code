//
//  PlayerButtonType.swift
//  Pineapple
//
//  Created by Caoife Davis on 16/12/2022.
//  Copyright © 2022 Pineapple Labs Limited. All rights reserved.
//

import Foundation

enum PlayerButtonType: Int, CaseIterable {
    case like
    case comment
    case share

    var text: String? {
        get {
            switch self {
            case .share:
                return nil
            default:
                return "0"
            }
        }
    }

    var iconImage: UIImage {
        get {
            switch self {
            case .comment:
                return #imageLiteral(resourceName: "playerCommentsButtonIcon")
            case .like:
                return #imageLiteral(resourceName: "playerLikeButtonIcon")
            case .share:
                return #imageLiteral(resourceName: "playerShareButtonIcon")
            }
        }
    }

    var selectedIconImage: UIImage? {
        get {
            switch self {
            case .like:
                return #imageLiteral(resourceName: "playerLikeFilledButtonIcon")
            default:
                return nil
            }
        }
    }

    var iconSize: CGFloat {
        get {
           return 24.0
        }
    }
}
