//
//  TabBarController.swift
//  Muk
//
//  Created by JINSEOK on 2023/03/15.
//

import UIKit

enum TabBarController {
    case mapViewContoller
    case userViewController
    case addListViewController
    
    var image: UIImage {
        switch self {
        case .mapViewContoller:
            return UIImage(named: "globe")!
        case .userViewController:
            return UIImage(named: "add.fill")!
        case .addListViewController:
            return UIImage(named: "user")!
        }
    }
}
