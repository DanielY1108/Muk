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
    
    var image: UIImage {
        switch self {
        case .mapVC:
            guard let image = UIImage(named: "globe") else { return UIImage() }
            return image.resized(to: CGSize(width: 27, height: 27))
        case .userVC:
            return UIImage(named: "user")!
        }
    }
    
    var selectedImage: UIImage {
        switch self {
        case .mapVC:
            guard let image = UIImage(named: "globe.fill") else { return UIImage() }
            return image.resized(to: CGSize(width: 27, height: 27))
        case .userVC:
            return UIImage(named: "user.fill")!
        }
    }
}
