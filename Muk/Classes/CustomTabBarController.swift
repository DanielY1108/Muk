//
//  CustomTabBarController.swift
//  Muk
//
//  Created by JINSEOK on 2023/03/13.
//

import UIKit

final class CustomTabBarController: UITabBarController {
    
    // MARK: - LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        setupTabBarController()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 너비만 수정가능, 높이 수정 시(아이콘을 중간으로 위치를 시키기 위해 origin.y 위치를 수동으로 변경해줘야 함)
        setupTabBarSize(emptyWidth: 50, height: 80)
    }
    
    // MARK: - Setup
    
    func configUI() {
        tabBar.unselectedItemTintColor = .gray
        tabBar.tintColor = .systemBlue
        tabBar.backgroundColor = UIColor(white: 0.2, alpha: 0.5)
        
        tabBar.layer.cornerRadius = tabBar.frame.height * 0.6
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner,
                                      .layerMinXMaxYCorner,
                                      .layerMaxXMinYCorner,
                                      .layerMaxXMaxYCorner]
    }
    
    func setupTabBarSize(emptyWidth: CGFloat, height: CGFloat = 80) {
        let tabBarWidth: CGFloat = view.frame.size.width - emptyWidth
        let tabBarHeight: CGFloat = height
        
        var tabBarFrame = tabBar.frame
        tabBarFrame.size.width = tabBarWidth
        tabBarFrame.origin.x = (view.frame.size.width - tabBarWidth) / 2

        // iPhoneX 일 경우 대응(height = 667, 기본 탭바 사이즈가 다른 것 같다.)
        if view.frame.size.height == 667 {
            tabBarFrame.size.height = tabBarHeight - 20
            tabBarFrame.origin.y = (view.frame.size.height - tabBarHeight)
        } else {
            tabBarFrame.size.height = tabBarHeight
            tabBarFrame.origin.y = (view.frame.size.height - tabBarHeight) - tabBarHeight/3
        }
        
        tabBar.frame = tabBarFrame
    }
    
    func setupTabBarController() {
        let mapViewController = MapViewController()
        mapViewController.tabBarItem.image = UIImage(systemName: "globe")
        
        let listViewController = ListViewController()
        listViewController.tabBarItem.image = UIImage(systemName: "list.bullet.rectangle.fill")
        
        let userViewController = UserViewController()
        userViewController.tabBarItem.image = UIImage(systemName: "person.fill")
        
        viewControllers = [mapViewController, listViewController, userViewController]
    }
    
}
