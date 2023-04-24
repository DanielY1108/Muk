//
//  UIFactory.swift
//  Muk
//
//  Created by JINSEOK on 2023/03/20.
//

import UIKit
import SnapKit

class UIFactory {
    
    static let sheard = UIFactory()
    
    private init() {}
    
    
    class func halfModalPresent(controller: UIViewController) {
        // iOS 15부터 사용 가능
        guard let sheet = controller.sheetPresentationController else { return }
        // 모달이 절반크기로 시작하고 확장이 가능
        sheet.detents = [.medium(), .large()]
        // true일 때 모달이 이전 컨트롤러와 크기가 같아질 때 스크롤 가능, false 하프 사이즈 부터 스크롤 사능
        sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        // 상단의 '-' 모양의 그랩바
        sheet.prefersGrabberVisible = true
    }
    
    
    
}

// MARK: - CustomTabBarController UI

extension UIFactory {
    // 중간 + 버튼 생성
    class func createMiddleButton(size: CGFloat) -> UIButton {
        // 현재 심볼 이미지를 변형(size, font 등)
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20,
                                                      weight: .heavy,
                                                      scale: .large)
        
        let button = UIButton(configuration: .plain())
        
        // configurationUpdateHandler: 버튼의 상태가 변경될 때 호출 되는 클로저
        // 강조 처리 끄기(클릭 시 회색) ios 15 부터는 adjustsImageWhenHighlighted 사용 불가
        // 대신 configurationUpdateHandler를 통해서 Highlight 설정을 해줘야 함.
        // isHighlighted는 UIButton의 상태(State)를 변경하는 것이므로 직접 버튼에 설정은 불가능하다 (핸들러를 통해서 작업 해줘야 함)
        button.configurationUpdateHandler = { btn in
            var config = btn.configuration
            // 이미지 설정
            config?.image = UIImage(systemName: "plus", withConfiguration: imageConfig)
            // 하이라이트
            btn.isHighlighted = false
            
            btn.configuration = config
        }
        
        // layout 설정
        button.snp.makeConstraints {
            $0.width.height.equalTo(size)
        }
        
        // 버튼 모양 설정
        button.layer.cornerRadius = size / 2
        
        // 버튼 그림자 설정
        button.layer.createShadow(size: size)
        
        // 버튼 색상
        button.tintColor = HexCode.unselected.color
        button.backgroundColor = HexCode.selected.color
        return button
    }
    
    /// Pop 버튼 생성
    /// - Parameters:
    ///   - size: 크기 (지름)
    ///   - isTapped: 버튼 클릭 여부 (Bool)
    /// - Returns: UIButton
    class func createPopButton(size: CGFloat ,isTapped: Bool) -> UIButton {
        
        let button = UIButton(type: .custom)
        
        button.backgroundColor = HexCode.selected.color
        
        // 오토 레이아웃 설정
        button.snp.makeConstraints {
            $0.width.height.equalTo(size)
        }
        
        // 원으로 만들기
        button.layer.cornerRadius = size / 2
        
        // ⭐️ 처음(기본) 값을 0으로 해줘야 점점 커지는 애니메이션이 가능
        button.transform = CGAffineTransform(scaleX: 0, y: 0)
        
        // 그림자
        button.layer.createShadow(size: size)
        
        // 조건문: 버튼을 클릭 시 (애니메이션 동작)
        if isTapped {
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
                // animations: 애니메이션 시작
                button.tintColor = .clear
                button.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            } completion: { _ in
                // completion: 완료 된 후 동작을 정의 (마지막 동작)
                button.tintColor = HexCode.unselected.color
                button.transform = CGAffineTransform.identity
            }
        }
        return button
    }
}

// MARK: - MapViewController UI

extension UIFactory {
    
    /// 현재 위치 버튼 생성
    /// - Parameter size: 크기 (지름)
    /// - Returns: UIButton
    class func createCurrentLocationButton(size: CGFloat) -> UIButton {
        
        let button = UIButton(type: .custom)
        
        //        let image = UIImage(named: "currentLocation")
        let image = UIImage(named: "currentLocation_v1")
        let resizedImage = image?.resized(to: size - 5,
                                          tintColor: HexCode.selected.color)
        
        button.setImage(resizedImage, for: .normal)
        
        button.backgroundColor = HexCode.unselected.color
        
        button.snp.makeConstraints {
            $0.width.height.equalTo(size)
        }
        
        button.layer.cornerRadius = size / 2
        
        button.layer.createShadow(size: size)
        
        return button
    }
}

// MARK: - ProfileViewController UI

extension UIFactory {
    // ProfileViewController 제목 설정
    class func createNavigationTitleLabel(_ title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.textColor = HexCode.selected.color
        label.font = .preferredFont(forTextStyle: .title2)
        
        return label
    }
}


// MARK: - DiaryViewController UI

extension UIFactory {
    
    // 다이어리 label 생성
    class func createDiaryLabel(title text: String, style: UIFont.TextStyle = .headline) -> UILabel {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: style)
        label.text = text
        label.textAlignment = .center
        
        return label
    }
    
    // 다이어리 textView 생성
    class func createDiaryTextView(placeHolder: String) -> UITextView {
        let textView = UITextView()
        textView.font = .preferredFont(forTextStyle: .subheadline)
        textView.layer.cornerRadius = 10
        textView.layer.borderWidth = 1
        textView.text = placeHolder
        textView.backgroundColor = .clear
        
        textView.snp.makeConstraints {
            $0.height.equalTo(80)
        }
        
        return textView
    }
    
    // 다이어리 stackView 생성
    class func createDiaryStackView(arrangedSubviews: [UIView], distribution: UIStackView.Distribution  = .fill, axis: NSLayoutConstraint.Axis = .vertical) -> UIStackView {
        
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.axis = axis
        stackView.spacing = 15
        stackView.distribution = distribution
        
        return stackView
    }
    
    // 다이어리 X 버튼 생성
    class func createCloseButton() -> UIButton {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "plus")
        config.buttonSize = .large
        
        let button = UIButton(configuration: config)
        button.tintColor = .black
        button.transform = CGAffineTransform(rotationAngle: CGFloat.pi/4)
        
        return button
    }
    
    // 다이어리 저장 버튼 생성
    class func createSaveButton() -> UIButton {
        var config = UIButton.Configuration.plain()
        config.title = "저장"
        config.buttonSize = .large
        
        let button = UIButton(configuration: config)
        button.tintColor = HexCode.selected.color
        button.layer.cornerRadius = 15
        
        return button
    }
    
    // 다이어리 이미지뷰 생성
    class func createCircleImageView(size: CGFloat) -> UIImageView {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = size/2
        imageView.clipsToBounds = true
        imageView.image = .add.withTintColor(HexCode.unselected.color)
        
        imageView.snp.makeConstraints {
            $0.width.height.equalTo(size)
        }
        
        return imageView
    }
}


// MARK: - PreView 읽기
import SwiftUI

#if DEBUG
struct PreView5: PreviewProvider {
    static var previews: some View {
        // 사용할 뷰 컨트롤러를 넣어주세요
        DiaryViewController()
            .toPreview()
    }
}
#endif
