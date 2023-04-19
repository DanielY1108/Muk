//
//  CustomTabBar.swift
//  Muk
//
//  Created by JINSEOK on 2023/04/19.
//

import UIKit

final class CustomTabBar: UITabBar {
    // MARK: - Properties
    
    private let eachSideSpace: CGFloat = 70
    private let addHeight: CGFloat = 11
    
    private lazy var subLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = HexCode.tabBarBackground.color.cgColor
        
        // tab bar layer 그림자 설정
        layer.path = pillShapePath.cgPath
        layer.shadowColor = HexCode.selected.color.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 1.0)  // 밑면 그림자 크기
        layer.shadowRadius = 5.0                              // 흐려지는 반경
        layer.shadowOpacity = 0.9                             // 불투명도 (0 ~ 1)
        return layer
    }()
    
    private lazy var pillShapePath = createCapsulePath(eachSide: eachSideSpace, addHeight: addHeight, on: self)
    
    // MARK: - life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTabBar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        drawTabBar()
    }
    
    // MARK: - Setup
   
    private func drawTabBar() {
        setupAppearance()
        addShape()
    }
    
    private func setupTabBar() {
        // 선택 시 틴트 컬러 설정
        self.tintColor = HexCode.selected.color
        self.unselectedItemTintColor = HexCode.unselected.color
    }
    
  
}


// MARK: - Drawing

extension CustomTabBar {
    
    private func setupAppearance() {
        // tab bar items 세팅 (UITabBarAppearance)
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()                        // Bar의 그림자 제거
        appearance.stackedItemWidth = (bounds.width - (eachSideSpace*2)) / 5   // 아이템들의 크기
        appearance.stackedItemPositioning = .centered                          // 아이템의 위치
        
        self.standardAppearance = appearance

        // 만약 appearance를 사용하면 예전 방식 설정들은 사용 못함!!!
        // self.itemWidth = (bounds.width - (eachSideSpace*2)) / 5
        // self.itemPositioning = .centered
    }
    
    
    private func addShape() {
        subLayer.path = pillShapePath.cgPath
        // tab bar layer 삽입: addSublayer대신 insertSublayer(0번째 Sublayer에 대치) 사용
        self.layer.insertSublayer(subLayer, at: 0)
    }
    
    
    // 알약 모양으로 UIBezierPath 생성
    private func createCapsulePath(eachSide space: CGFloat, addHeight: CGFloat ,on tabBar: UITabBar) -> UIBezierPath {
        
        let x: CGFloat = space                                  // x 축으로 이동한 거리 (여백)
        let width: CGFloat = tabBar.bounds.width - (x * 2)      // 크기: 탭바의 너비(390) - (여백 * 2)
        let baseHeight: CGFloat = 49                            // 기본 높이
        let currentHeight: CGFloat = baseHeight + addHeight     // 높이를 설정 (기본높이 + 추가 높이)
        let y: CGFloat = -(5.5 + addHeight/2)                   // Y축 = 아이콘과 타이틀의 중간 위치 값
        
        // 알약 모양으로 UIBezierPath 생성
        let path = UIBezierPath(roundedRect: CGRect(x: x, y: y, width: width, height: currentHeight),
                                cornerRadius: currentHeight / 2)
        
        return path
    }
}



