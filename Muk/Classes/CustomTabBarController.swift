//
//  CustomTabBarController.swift
//  Muk
//
//  Created by JINSEOK on 2023/03/13.
//

import UIKit

final class CustomTabBarController: UITabBarController {
    
    // MARK: - Properties
    
    // MARK: - LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()

        setupTabBarItems()
    }
    
    // MARK: - Setup
    func setupTabBar() {
        // CAShapeLayer 객체 생성
        let layer = CAShapeLayer()
        
        // tab bar layer 세팅
        let x: CGFloat = 50                                       // x 축으로 이동한 거리 (여백)
        let width: CGFloat = tabBar.bounds.width - (x * 2)        // 크기: 탭바의 너비(390) - (여백 * 2)
        let height: CGFloat = 60                                  // 높이를 설정
        let y: CGFloat = (tabBar.bounds.midY - 5.5) - height / 2  // Y축 = (아이콘의 중간 위치 값) - 높이의 절반
        
        // 알약 모양으로 UIBezierPath 생성
        let path = UIBezierPath(roundedRect: CGRect(x: x,
                                                    y: y,
                                                    width: width,
                                                    height: height),
                                cornerRadius: height / 2).cgPath
        layer.path = path

        layer.fillColor = HexCode.tabBarBackground.color.cgColor
        
        // tab bar layer 그림자 설정
        layer.shadowColor = HexCode.selected.color.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 1.0)  // 밑면 그림자 크기
        layer.shadowRadius = 5.0                              // 흐려지는 반경
        layer.shadowOpacity = 0.5                             // 불투명도 (0 ~ 1)
        
        // tab bar layer 삽입: addSublayer대신 insertSublayer(0번째 Sublayer에 대치) 사용
        tabBar.layer.insertSublayer(layer, at: 0)
        
        // tab bar items 세팅
        tabBar.itemWidth = width / 5
        tabBar.itemPositioning = .centered
        
        // 틴트 컬러 설정
        tabBar.tintColor = HexCode.selected.color
        tabBar.unselectedItemTintColor = HexCode.unselected.color
    }
    
    
    func setupTabBarItems() {
        let mapViewController = MapViewController()
        mapViewController.tabBarItem.image = UIImage(named: "globe")
        mapViewController.tabBarItem.selectedImage = UIImage(named: "globe.fill")
        
        let listViewController = AddListViewController()
        listViewController.tabBarItem.image = UIImage(named: "add.fill")
        
        let userViewController = UserViewController()
        userViewController.tabBarItem.image = UIImage(named: "user")
        userViewController.tabBarItem.selectedImage = UIImage(named: "user.fill")
        
        viewControllers = [mapViewController, listViewController, userViewController]
    }
    
}



// MARK: - PreView
import SwiftUI

#if DEBUG
struct PreView: PreviewProvider {
    static var previews: some View {
        // 사용할 뷰 컨트롤러를 넣어주세요
        CustomTabBarController()
            .toPreview()
    }
}
#endif



