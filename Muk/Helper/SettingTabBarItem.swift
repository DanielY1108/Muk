//
//  TabBarItem.swift
//  Muk
//
//  Created by JINSEOK on 2023/03/15.
//

import UIKit

enum TabBarItems: CaseIterable {
    case mapVC
    case addActions
    case userVC
    
    enum ImageOption {
        case noraml
        case filled
    }
    
    func setImage(_ option: ImageOption) -> UIImage? {
        
        switch self {
        case .mapVC:
            if option == .noraml {
                guard let image = UIImage(named: "globe") else { return UIImage() }
                return image.resized(to: 30)
            } else {
                guard let image = UIImage(named: "globe.fill") else { return UIImage() }
                return image.resized(to: 30)
            }
        case .addActions:
            return nil
        case .userVC:
            if option == .noraml {
                guard let image = UIImage(named: "user") else { return UIImage() }
                return image.resized(to: 28)
            } else {
                guard let image = UIImage(named: "user.fill") else { return UIImage() }
                return image.resized(to: 28)
            }
        }
    }
}
