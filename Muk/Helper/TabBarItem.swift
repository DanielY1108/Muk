//
//  TabBarItem.swift
//  Muk
//
//  Created by JINSEOK on 2023/03/15.
//

import UIKit

enum TabBarItem {
    case mapVC
    case userVC
    case addListVC
    
    var image: UIImage {
        switch self {
        case .mapVC:
            return UIImage(named: "globe")!
        case .userVC:
            return UIImage(named: "add.fill")!
        case .addListVC:
            return UIImage(named: "user")!
        }
    }
    
    var selectedImage: UIImage {
        switch self {
        case .mapVC:
            return UIImage(named: "globe.fill")!
        case .userVC:
            return UIImage(named: "add.fill")!
        case .addListVC:
            return UIImage(named: "user.fill")!

        }
    }
}
