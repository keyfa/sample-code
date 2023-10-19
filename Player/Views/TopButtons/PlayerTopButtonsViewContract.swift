//
//  PlayerTopButtonsViewContract.swift
//  Pineapple
//
//  Created by Caoife Davis on 16/12/2022.
//  Copyright © 2022 Pineapple Labs Limited. All rights reserved.
//

import Foundation

protocol PlayerTopButtonsViewDelegate: AnyObject {
    func didTapReportButton()
    func didTapActionButton()
    func didTapShareButton()
}

extension PlayerTopButtonsViewDelegate {
    func didTapReportButton() {}
    func didTapActionButton() {}
}
