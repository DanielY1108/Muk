//
//  CustomTabBarController.swift
//  Muk
//
//  Created by JINSEOK on 2023/03/13.
//

import UIKit
import SnapKit

final class CustomTabBarController: UITabBarController {
    
    // MARK: - Properties
    let middleButton: UIButton = {
        let button = UIButton()
        // 현재 심볼 이미지를 변형(size, font 등)
        let configuation = UIImage.SymbolConfiguration(pointSize: 20,
                                                       weight: .heavy,
                                                       scale: .large)
        
        button.setImage(UIImage(systemName: "plus", withConfiguration: configuation),
                        for: .normal)
        
        
        button.tintColor = HexCode.unselected.color
        button.backgroundColor = HexCode.selected.color
        return button
    }()
    
    // MARK: - LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBarItems()
        setupTabBar()
    }
    
    // MARK: - Setup
    func setupTabBar() {
        // CAShapeLayer 객체 생성
        let layer = CAShapeLayer()
        
        // tab bar layer 세팅
        let x: CGFloat = 50                                       // x 축으로 이동한 거리 (여백)
        let width: CGFloat = self.tabBar.bounds.width - (x * 2)        // 크기: 탭바의 너비(390) - (여백 * 2)
        let height: CGFloat = 60                                  // 높이를 설정
        let y: CGFloat = (self.tabBar.bounds.midY - 5.5) - height / 2  // Y축 = (아이콘의 중간 위치 값) - 높이의 절반
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
        self.tabBar.layer.insertSublayer(layer, at: 0)
        
        // tab bar items 세팅
        self.tabBar.itemWidth = width / 5
        self.tabBar.itemPositioning = .centered
        
        // 틴트 컬러 설정
        self.tabBar.tintColor = HexCode.selected.color
        self.tabBar.unselectedItemTintColor = HexCode.unselected.color
        
        addMiddleButton()
    }
    
    // add 버튼 세팅
    func addMiddleButton() {
        
        // 만든 버튼을 네이게이션 아이템 대신 사용할 것이므로 미리 클릭을 방지.
        DispatchQueue.main.async {
            if let items = self.tabBar.items {
                items[1].isEnabled = false
            }
        }
        
        tabBar.addSubview(middleButton)
        
        let size: CGFloat = 38
        
        // layout 설정
        middleButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            // FIXME: - 왜 중간정렬이 될까요?? 운 좋게 떨어진건가? 수정 요망
            $0.top.equalToSuperview()
            $0.width.height.equalTo(size)
        }
        
        // 버튼 모양 설정
        middleButton.layer.cornerRadius = size / 2
        middleButton.layer.masksToBounds = false
        
        // 버튼 그림자 설정
        middleButton.layer.shadowColor = HexCode.selected.color.cgColor
        middleButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        middleButton.layer.shadowOpacity = 0.5
        middleButton.layer.shadowRadius = 10
        
        // 버튼 동작 생성
        middleButton.addTarget(self, action: #selector(buttonHandler), for: .touchUpInside)
    }
    
    @objc func buttonHandler(sender: UIButton) {
        
    }
    
    // 탭바에 뷰컨트롤러 연결
    func setupTabBarItems() {
        let mapViewController = MapViewController()
        mapViewController.tabBarItem.image = TabBarItem.mapVC.image
        mapViewController.tabBarItem.selectedImage = TabBarItem.mapVC.selectedImage
        
        let listViewController = AddListViewController()
        //        listViewController.tabBarItem.image = UIImage(named: "add.fill")
        
        let userViewController = UserViewController()
        userViewController.tabBarItem.image = TabBarItem.userVC.image
        userViewController.tabBarItem.selectedImage = TabBarItem.userVC.image
        
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




