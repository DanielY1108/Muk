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
    
    // MARK: - LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBar()
    }
    
    // MARK: - Setup
    
    // 탭바를 설정
    private func setupTabBar() {
        setupTabBarItems()
        setupTabBarUI()
        setupMiddleButton()

        self.delegate = self
    }
    
    // 탭바 UI 설정
    private func setupTabBarUI() {
        // CAShapeLayer 객체 생성
        let layer = CAShapeLayer()
        
        // tab bar layer 세팅
        let x: CGFloat = 70                                       // x 축으로 이동한 거리 (여백)
        let width: CGFloat = self.tabBar.bounds.width - (x * 2)   // 크기: 탭바의 너비(390) - (여백 * 2)
        let height: CGFloat = 50                                  // 높이를 설정
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
        layer.shadowOffset = CGSize(width: 0.0, height: -1.0)  // 밑면 그림자 크기
        layer.shadowRadius = 5.0                              // 흐려지는 반경
        layer.shadowOpacity = 0.9                             // 불투명도 (0 ~ 1)
        
        // tab bar layer 삽입: addSublayer대신 insertSublayer(0번째 Sublayer에 대치) 사용
        self.tabBar.layer.insertSublayer(layer, at: 0)
        
        // tab bar items 세팅 (UITabBarAppearance)
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()  // Bar의 그림자 제거
        appearance.stackedItemWidth = width / 5          // 아이템들의 크기
        appearance.stackedItemPositioning = .centered    // 아이템의 위치

        self.tabBar.standardAppearance = appearance
        
        // 만약 appearance를 사용하면 예전 방식 설정들은 사용 못함!!!
//        self.tabBar.itemWidth = width / 5
//        self.tabBar.itemPositioning = .centered
        
        // 틴트 컬러 설정
        self.tabBar.tintColor = HexCode.selected.color
        self.tabBar.unselectedItemTintColor = HexCode.unselected.color
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
    // 탭바를 클릭 했을 때 중간버튼 동작 안하게 만들고 만약 UserVC를 선택 시 "X"로 변경되는 애니메이션 처리
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        middleButtonAnimationEnd()
        
        switch viewController {
        case self.viewControllers?.first:
            middleButton.isUserInteractionEnabled = true
        case self.viewControllers?.last:
            // 버튼을 disable하면 틴트색 조절을 하기 위해 UIGraphicsImageRenderer 작업이 필요하지만,
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
        
        let size: CGFloat = 45
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
            self.setupPopButton(count: popButtonCount, radius: 72)
            
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
