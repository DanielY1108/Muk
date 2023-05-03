//
//  CustomTabBarController.swift
//  Muk
//
//  Created by JINSEOK on 2023/03/13.
//

import UIKit
import SnapKit

protocol CustomTabBarControllerDelegate: AnyObject {
    func didSelectPopButton(viewController: CustomTabBarController, presentController: UIViewController)
}

final class CustomTabBarController: UITabBarController {
    
    weak var customDelegate: CustomTabBarControllerDelegate?
    
    // MARK: - Properties
    
    private let customTabBar = CustomTabBar()
    
    // 중간 버튼 생성
    private let middleButtonSize: CGFloat = 50
    private lazy var middleButton = UIFactory.createMiddleButton(size: middleButtonSize)
    
    // 중간 버튼 클릭 시 Bool로 동작을 제어하기 위해 플래그를 박아둠
    private var middleButtonTapped = false
    
    // pop 버튼을 탭바에 사용할 수 있도록 프로퍼티로 생성
    var popButtons = PopButtons()
    
    
    
    // MARK: - LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - Setup
    
    // 탭바를 설정
    private func setupTabBar() {
        setValue(customTabBar, forKey: "tabBar")
        self.delegate = self
        setupTabBarItems()
        setupMiddleButton()
    }
    
    // 탭바를 뷰 컨트롤러 연결
    private func setupTabBarItems() {
        self.viewControllers = TabBarItems.allCases.map {
            return viewControllerForTabBarItem($0)
        }
        
        // DiaryVC에서 델리게이트로 데이터를 전달하려면 profileVC를 한번은 실행시켜줘야 델리게이트가 동작
        self.selectedViewController = self.viewControllers?[TabBarItems.profileVC.rawValue]
        DispatchQueue.main.async {
            self.selectedViewController = self.viewControllers?[TabBarItems.mapVC.rawValue]
        }
    }
    
    private func viewControllerForTabBarItem(_ itme: TabBarItems) -> UIViewController {
        switch itme {
        case .mapVC:
            let mapViewController = MapViewController()
            mapViewController.tabBarItem.image = TabBarItems.mapVC.setImage(.noraml)
            mapViewController.tabBarItem.selectedImage = TabBarItems.mapVC.setImage(.filled)
            return mapViewController
        case .addActions:
            return UIViewController()
        case .profileVC:
            let profileViewController = ProfileViewController()
            let profileNavigationController = UINavigationController(rootViewController: profileViewController)
            profileViewController.tabBarItem.image = TabBarItems.profileVC.setImage(.noraml)
            profileViewController.tabBarItem.selectedImage = TabBarItems.profileVC.setImage(.filled)
            return profileNavigationController
        }
    }
}

// MARK: - 탭바 컨트롤러 델리게이트

extension CustomTabBarController: UITabBarControllerDelegate {

    // 만약 UserVC를 선택 시 버튼이 "X"로 변경되는 애니메이션 처리
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        middleButtonAnimationEnd(anitaion: false)

        switch viewController {
        case is MapViewController:
            middleButton.isUserInteractionEnabled = true
        default:
            // 버튼을 disable하면 틴트색이 회색으로 변한다. 틴트 조절을 하기 위해 UIGraphicsImageRenderer 작업이 필요하지만,
            // 이렇게 터치만 안되게 설정만들어 주면 틴트 설정을 건드릴 필요 없이 코드가 짧아진다.
            middleButton.isUserInteractionEnabled = false
            middleButtonAnimationStart(anitaion: true)
        }
    }
}

// MARK: - 중간(add) 버튼 세팅
extension CustomTabBarController {
    // add 버튼 세팅
    private func setupMiddleButton() {
        self.tabBar.addSubview(middleButton)

        // 네이게이션 아이템 대신 버튼을 사용할 것이므로, 비활성화 시켜 클릭을 방지.
        DispatchQueue.main.async {
            if let items = self.tabBar.items {
                items[1].isEnabled = false
            }
        }
        
        // layer의 중간 위치 (layer 높이/2 - 기본 layer에서 추가된 높이 - 버튼 사이즈/2)
        let y: CGFloat = (customTabBar.currentHeight/2) - customTabBar.addHeight - (middleButtonSize/2)
        
        // layout 설정
        middleButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(y)
        }
        
        // 버튼 동작 생성
        middleButton.addTarget(self, action: #selector(middleButtonHandler), for: .touchUpInside)
    }
    
    // 중간 버튼 핸들러
    @objc func middleButtonHandler(sender: UIButton) {
        
        if !middleButtonTapped {
            // 버튼 클릭 시 할 작업 - pop 버튼 생성, 시작 애니메이션
            middleButtonAnimationStart(anitaion: true)

            self.setupPopButton(radius: 80)
            
        } else {
            // 버튼 취소 시 할 작업 - pop 버튼 제거, 끝 애니메이션
            middleButtonAnimationEnd(anitaion: false)
        }
    }
    
    // 중간 버튼 시작 애니메이션
    func middleButtonAnimationStart(anitaion: Bool) {
        
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
            
            self.middleButtonTapped = anitaion
        }
    }
    
    // 중간 버튼 끝 애니메이션
    func middleButtonAnimationEnd(anitaion: Bool) {
        
        UIView.animate(withDuration: 0.3) {
            self.middleButton.transform = CGAffineTransform.identity
            // 버튼 색상 설정
            self.middleButton.tintColor = HexCode.unselected.color
            self.middleButton.backgroundColor = HexCode.selected.color
            
            // 버튼 테두리 설정
            self.middleButton.layer.borderWidth = 0
            
            self.middleButtonTapped = anitaion
        }
        
        // 버튼 취소 시 할 작업 (pop 버튼 제거)
        self.removePopButton()
    }
    
}


// MARK: - pop 버튼 세팅
extension CustomTabBarController {
    // pop 버튼 셋팅
    private func setupPopButton(radius: CGFloat) {
        // 45° 마다 배치
        let degrees: CGFloat = 45
        
        // 만약에 버튼의 갯수 및 이미지등을 변경하고 싶으면 구조체 PopButtons에서 변경
        let popButtonCount = self.popButtons.options.count

        for _ in 0 ..< popButtonCount {
            
            let button = UIFactory.createPopButton(size: 40, isTapped: self.middleButtonTapped)
            
            self.popButtons.buttons.append(button)
        }
        
        for (index, button) in popButtons.buttons.enumerated() {
            
            self.view.addSubview(button)
            // 버튼 태그
            button.tag = index
            
            // 1° = (π / 180) rad
            // x = cos(a) * r = cos(각도) * 반지름
            // y = sin(a) * r = sin(각도) * 반지름
            let x = cos(degrees * CGFloat(index+1) * .pi/180) * radius
            let y = sin(degrees * CGFloat(index+1) * .pi/180) * radius
            
            button.snp.makeConstraints {
                $0.centerX.equalTo(tabBar).offset(-x)
                // top으로 중간 버튼 레이아웃을 잡았으므로 여기서도 top으로 설정
                $0.top.equalTo(tabBar).offset(-y)
            }
            
            button.setImage(popButtons.options[index].image, for: .normal)
            
            // pop 버튼이 가장 앞쪽으로 위치하게 만듬
            self.view.bringSubviewToFront(button)
            
            button.addTarget(self, action: #selector(popButtonHandler), for: .touchUpInside)
        }
    }
    
    // pop 버튼 핸들러
    @objc func popButtonHandler(sender: UIButton) {
        
        middleButtonAnimationEnd(anitaion: false)
        
        switch sender.tag {
        case 0:
            print("Search")
        case 1:
            print("Current Location")
            let diaryVC = DiaryViewController()
            customDelegate?.didSelectPopButton(viewController: self, presentController: diaryVC)
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
            
            UIView.animate(withDuration: 0.3) {
                button.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            } completion: { _ in
                DispatchQueue.main.async {
                    button.removeFromSuperview()
                    self.popButtons.buttons.removeAll()
                }
            }
        }
    }
}
