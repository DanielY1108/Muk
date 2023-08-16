//
//  CustomTabBar.swift
//  Muk
//
//  Created by JINSEOK on 2023/04/19.
//

import UIKit

final class CustomTabBar: UITabBar {
    
    // MARK: - Properties
    
    private var x: CGFloat = 70                                    // X 축으로 이동한 거리 (여백)
    private lazy var width: CGFloat = self.bounds.width - (x*2)    // 너비: 기본 탭바의 너비 - (여백 * 2)
    
    private(set) var height: CGFloat = 60                           // 높이
    private lazy var initialImageY: CGFloat = 19 - (height/2)       // 이미지 중심을 탭바 Y축 원점으로 위치(19) - (높이/2)
    private(set) lazy var y: CGFloat = initialImageY                // Y축: 이미지를 중간에 위치시킨 Y축 값

    private let subLayer = CAShapeLayer()
    
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
        appearance.configureWithTransparentBackground()           // Bar의 그림자 제거
        appearance.stackedItemPositioning = .centered             // 아이템의 위치
        appearance.stackedItemWidth = width / 5                   // 아이템들의 크기
        
        self.standardAppearance = appearance

        // 만약 appearance를 사용하면 예전 방식 설정들은 사용 못함!!!
        // self.itemWidth = (bounds.width - (eachSideSpace*2)) / 5
        // self.itemPositioning = .centered
    }
    
    private func addShape() {
        // 배경 레이어 (알약 모양)
        let pillShapePath = createCapsulePath()
        
        subLayer.fillColor = HexCode.tabBarBackground.color.cgColor
        subLayer.path = pillShapePath.cgPath
        
        // tab bar layer 그림자 설정
        subLayer.createShadow(path: pillShapePath)
        
        // tab bar layer 삽입: addSublayer대신 insertSublayer(0번째 Sublayer에 대치) 사용
        self.layer.insertSublayer(subLayer, at: 0)
    }
    
    // 알약 모양으로 UIBezierPath 생성
    private func createCapsulePath() -> UIBezierPath {
        
        // 알약 모양으로 UIBezierPath 생성
        let path = UIBezierPath(roundedRect: CGRect(x: x, y: y, width: width, height: height),
                                cornerRadius: height / 2)
        return path
    }
}
