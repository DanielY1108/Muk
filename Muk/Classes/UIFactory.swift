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
    
    /// 팝업버튼 생성
    /// - Parameters:
    ///   - size: 지름
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
        
        // 기본 스케일 0으로 시작해야 애니메이션 처리
        button.bounds.size = CGSize(width: 0, height: 0)
        button.transform = CGAffineTransform(scaleX: 0, y: 0)
        
        // 그림자
        button.layer.shadowColor = HexCode.selected.color.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowOpacity = 0.9
        button.layer.shadowRadius = 5


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
