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
    var buttonTapped = false  // 버튼 클릭 시 Bool로 동작을 제어하기 위해 플래그를 박아둠
        
    // 버튼 생성
    let middleButton: UIButton = {
        let button = UIButton()
        // 현재 심볼 이미지를 변형(size, font 등)
        let configuation = UIImage.SymbolConfiguration(pointSize: 18,
                                                       weight: .heavy,
                                                       scale: .large)
        
        button.setImage(UIImage(systemName: "plus", withConfiguration: configuation),
                        for: .normal)
        
        // 버튼 색상
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
        let width: CGFloat = self.tabBar.bounds.width - (x * 2)   // 크기: 탭바의 너비(390) - (여백 * 2)
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
        
        // 네이게이션 아이템 대신 버튼을 사용할 것이므로 비활성화 시켜 클릭을 방지.
        DispatchQueue.main.async {
            if let items = self.tabBar.items {
                items[1].isEnabled = false
            }
        }
        
        tabBar.addSubview(middleButton)
        
        let size: CGFloat = 38
        let y: CGFloat = (self.tabBar.bounds.midY - 5.5) - size / 2  // Y축 = (아이콘의 중간 위치 값) - 높이의 절반

        // layout 설정
        middleButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            // 왜 top으로 설정하면 중간 정렬이 될까요?
            $0.top.equalToSuperview().offset(y)
            $0.width.height.equalTo(size)
        }
        
        // 버튼 모양 설정
        middleButton.layer.cornerRadius = size / 2
        
        // 강조 처리 끄기(클릭 시 회색)
        middleButton.adjustsImageWhenHighlighted = false
        
        // 버튼 그림자 설정
        middleButton.layer.shadowColor = HexCode.selected.color.cgColor
        middleButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        middleButton.layer.shadowOpacity = 0.5
        middleButton.layer.shadowRadius = 1
        
        // 버튼 동작 생성
        middleButton.addTarget(self, action: #selector(buttonHandler), for: .touchUpInside)
    }
    
    @objc func buttonHandler(sender: UIButton) {
    
        if buttonTapped == false {
            
            UIView.animate(withDuration: 0.3) {
                // pi = 180°, 4로 나눠준다면 45° 회전
                let transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
                self.middleButton.transform = transform
                // 버튼 색상 설정
                self.middleButton.tintColor = HexCode.selected.color
                self.middleButton.backgroundColor = HexCode.unselected.color
                
                // 버튼 테두리 설정
                self.middleButton.layer.borderWidth = 4
                self.middleButton.layer.borderColor = HexCode.selected.color.cgColor
                
                self.buttonTapped = true
                
                // TODO: - 버튼 클릭 시 할 작업을 추가해야 함
                
            }
        } else {
            
            UIView.animate(withDuration: 0.3) {
                self.middleButton.transform = CGAffineTransform.identity
                // 버튼 색상 설정
                self.middleButton.tintColor = HexCode.unselected.color
                self.middleButton.backgroundColor = HexCode.selected.color
                
                // 버튼 테두리 설정
                self.middleButton.layer.borderWidth = 0
                
                self.buttonTapped = false
                
                // TODO: - 버튼 취소 시 할 작업을 추가해야 함

            }
        }
    }
    
    // 탭바에 뷰컨트롤러 연결
    func setupTabBarItems() {
        let mapViewController = MapViewController()
        mapViewController.tabBarItem.image = SettingTabBarItem.mapVC.image
        mapViewController.tabBarItem.selectedImage = SettingTabBarItem.mapVC.filledImage
        
        let addViewController = UIViewController()
        
        let userViewController = UserViewController()
        userViewController.tabBarItem.image = SettingTabBarItem.userVC.image
        userViewController.tabBarItem.selectedImage = SettingTabBarItem.userVC.filledImage
        
        viewControllers = [mapViewController, addViewController, userViewController]
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





