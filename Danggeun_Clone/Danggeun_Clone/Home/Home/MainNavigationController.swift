//
//  MainNavigationController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/12/15.
//

import UIKit

// MARK: [Class or Struct] ----------
class MainNavigationController: UINavigationController {

    // MARK: [Override] ----------
    override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
}
