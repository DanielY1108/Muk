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
    
    // pop 버튼을 탭바에 사용할 수 있도록 프로퍼티로 생성
    private var popButtons = PopButtons()
    
    private var buttonTapped = false  // 중간 버튼 클릭 시 Bool로 동작을 제어하기 위해 플래그를 박아둠
    
    // 버튼 생성
    private let middleButton = UIFactory.createMiddleButton()
    
    private let customTabBar = CustomTabBar()
    
    // MARK: - LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupMiddleButton()
    }
    
    // MARK: - Setup
    
    // 탭바를 설정
    private func setupTabBar() {
        setValue(customTabBar, forKey: "tabBar")
        self.delegate = self
        setupTabBarItems()
    }
    
    
    // 탭바에 뷰 컨트롤러 연결
    private func setupTabBarItems() {
        let mapViewController = MapViewController()
        mapViewController.tabBarItem.image = SettingTabBarItem.mapVC.setImage(.noraml)
        mapViewController.tabBarItem.selectedImage = SettingTabBarItem.mapVC.setImage(.filled)
        
        let addViewController = UIViewController()
        
        let profileViewController = ProfileViewController()
        let profileNavigationController = UINavigationController(rootViewController: profileViewController)
        profileViewController.tabBarItem.image = SettingTabBarItem.userVC.setImage(.noraml)
        profileViewController.tabBarItem.selectedImage = SettingTabBarItem.userVC.setImage(.filled)
        
        self.viewControllers = [mapViewController, addViewController, profileNavigationController]
    }
    
}

// MARK: - 탭바 컨트롤러 델리게이트
extension CustomTabBarController: UITabBarControllerDelegate {
    // 만약 UserVC를 선택 시 버튼이 "X"로 변경되는 애니메이션 처리
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        middleButtonAnimationEnd()
        
        switch viewController {
        case self.viewControllers?.first:
            middleButton.isUserInteractionEnabled = true
        case self.viewControllers?.last:
            // 버튼을 disable하면 틴트색이 회색으로 변한다. 틴트 조절을 하기 위해 UIGraphicsImageRenderer 작업이 필요하지만,
            // 이렇게 터치만 안되게 설정만들어 주면 틴트 설정을 건드릴 필요 없이 코드가 짧아진다.
            middleButton.isUserInteractionEnabled = false
            middleButtonAnimationStart()
        default: break
        }
    
        return true
    }
}

// MARK: - 중간(add) 버튼 세팅
extension CustomTabBarController {
    // add 버튼 세팅
    private func setupMiddleButton() {
        
        // 네이게이션 아이템 대신 버튼을 사용할 것이므로, 비활성화 시켜 클릭을 방지.
        DispatchQueue.main.async {
            if let items = self.tabBar.items {
                items[1].isEnabled = false
            }
        }
        
        self.tabBar.addSubview(middleButton)
        
        let size: CGFloat = 50
        let y: CGFloat = 30 - 11 - (size/2)   // (layer 높이/2 - layer에서 추가된 높이 - 버튼 사이즈/2)
        
        // layout 설정
        middleButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(y)
            $0.width.height.equalTo(size)
        }
        
        // 버튼 모양 설정
        middleButton.layer.cornerRadius = size / 2
        
        // 버튼 그림자 설정
        middleButton.layer.shadowColor = HexCode.selected.color.cgColor
        middleButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        middleButton.layer.shadowOpacity = 0.9
        middleButton.layer.shadowRadius = 5
        
        // 버튼 동작 생성
        middleButton.addTarget(self, action: #selector(middleButtonHandler), for: .touchUpInside)
    }
    
    // 중간 버튼 핸들러
    @objc func middleButtonHandler(sender: UIButton) {
        
        if buttonTapped == false {
            // 버튼 클릭 시 할 작업 - pop 버튼 생성, 시작 애니메이션
            middleButtonAnimationStart()
            
            let popButtonCount = self.popButtons.options.count
            self.setupPopButton(count: popButtonCount, radius: 80)
            
        } else {
            // 버튼 취소 시 할 작업 - pop 버튼 제거, 끝 애니메이션
            middleButtonAnimationEnd()
        }
    }
    
    // 중간 버튼 시작 애니메이션
    private func middleButtonAnimationStart() {
        
        UIView.animate(withDuration: 0.5) {
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
        }
    }
    
    // 중간 버튼 끝 애니메이션
    private func middleButtonAnimationEnd() {
        
        UIView.animate(withDuration: 0.3) {
            self.middleButton.transform = CGAffineTransform.identity
            // 버튼 색상 설정
            self.middleButton.tintColor = HexCode.unselected.color
            self.middleButton.backgroundColor = HexCode.selected.color
            
            // 버튼 테두리 설정
            self.middleButton.layer.borderWidth = 0
            
            self.buttonTapped = false
        }
        
        // 버튼 취소 시 할 작업 (pop 버튼 제거)
        self.removePopButton()
    }
    
}

// MARK: - pop 버튼 세팅
extension CustomTabBarController {
    // pop 버튼 셋팅
    private func setupPopButton(count: Int, radius: CGFloat) {
        // 45° 마다 배치
        let degrees: CGFloat = 45
        
        for i in 0 ..< count {
            
            let button = UIFactory.createPopButton(size: 40, isTapped: self.buttonTapped)
            
            self.view.addSubview(button)
            self.popButtons.buttons.append(button)
            
            // 버튼 태그
            button.tag = i
            
            // 1° = (π / 180) rad
            // x = cos(a) * r = cos(각도) * 반지름
            // y = sin(a) * r = sin(각도) * 반지름
            let x = cos(degrees * CGFloat(i+1) * .pi/180) * radius
            let y = sin(degrees * CGFloat(i+1) * .pi/180) * radius
            
            button.snp.makeConstraints {
                $0.centerX.equalTo(self.tabBar).offset(-x)
                // top으로 중간 버튼 레이아웃을 잡았으므로 여기서도 top으로 설정
                $0.top.equalTo(self.tabBar).offset(-y)
            }
            
            button.setImage(popButtons.options[i].image, for: .normal)
            
            // pop 버튼이 가장 앞쪽으로 위치하게 만듬
            self.view.bringSubviewToFront(button)
            
            button.addTarget(self, action: #selector(popButtonHandler), for: .touchUpInside)
        }
    }
    
    // pop 버튼 핸들러
    @objc func popButtonHandler(sender: UIButton) {
        
        middleButtonAnimationEnd()
        
        switch sender.tag {
        case 0:
            print("Search")
        case 1:
            print("Current Location")
            let diaryVC = DiaryViewController()
            diaryVC.modalPresentationStyle = .fullScreen
            self.present(diaryVC, animated: true)
        default:
            print("Pin")
        }
    }
    
    // pop 버튼 삭제
    private func removePopButton() {
        
        let popButtons = self.popButtons.buttons
        
        for button in popButtons {
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                button.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            } completion: { _ in
                button.removeFromSuperview()
            }
        }
    }
}
