//
//  CustomTabBar.swift
//  Muk
//
//  Created by JINSEOK on 2023/04/19.
//

import UIKit

final class CustomTabBar: UITabBar {
    
    // MARK: - Properties
    
    private let eachSideSpace: CGFloat = 70    // 탭바의 각 사이드 공간의 크기
    let addHeight: CGFloat = 11        // 49 + 추가할 만큼 크기를 조정
    
    // 아래 크기를 정하는 변수 수정 금지 (사용만 가능)
    private let fixedY: CGFloat = 5.5          // 타이틀 없이 이미지만 사용 시 Y축의 -(5.5 + 추가된 높이의 절반)이 필요.
    private let defaultTabBarHeight: CGFloat = 49
    
    private(set) lazy var currentHeight: CGFloat = defaultTabBarHeight + addHeight         // 높이: 기본 탭바 높이 + 추가 높이
    private(set) lazy var currentWidth: CGFloat = self.bounds.width - (2 * eachSideSpace)  // 크기: 기본 탭바 너비(390) - (여백 * 2)
    private(set) lazy var x: CGFloat = eachSideSpace                                       // X축으로 이동한 거리 (여백)
    private(set) lazy var y: CGFloat = -(addHeight/2 + fixedY)                             // 이미지 기준, 높이의 절반 위치

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
        appearance.stackedItemWidth = currentWidth / 5            // 아이템들의 크기
        
        self.standardAppearance = appearance

        // 만약 appearance를 사용하면 예전 방식 설정들은 사용 못함!!!
        // self.itemWidth = (bounds.width - (eachSideSpace*2)) / 5
        // self.itemPositioning = .centered
    }
    
    private func addShape() {
        // 배경 레이어 (알약 모양)
        var pillShapePath = createCapsulePath()
        
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
        let path = UIBezierPath(roundedRect: CGRect(x: x, y: y, width: currentWidth, height: currentHeight),
                                cornerRadius: currentHeight / 2)
        return path
    }
}
