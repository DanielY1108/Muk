//
//  CALayer+Shadow.swift
//  Muk
//
//  Created by JINSEOK on 2023/04/20.
//

import UIKit

extension CALayer {
    
    func createShadow(path: UIBezierPath) {
        self.shadowPath = path.cgPath
        self.shadowColor = HexCode.selected.color.cgColor   // 그림자 색
        self.shadowOffset = CGSize(width: 0, height: 1)     // 밑면 그림자 크기
        self.shadowOpacity = 0.9                            // 불투명도 (0 ~ 1)
        self.shadowRadius = 2                               // 흐려지는 반경
    }
    
    func createShadow(size: CGFloat) {
        let currnetSize = CGSize(width: size, height: size)
        let currnetRect = CGRect(origin: .zero, size: currnetSize)
        let path = UIBezierPath(roundedRect: currnetRect, cornerRadius: cornerRadius)
        
        self.shadowPath = path.cgPath
        self.shadowColor = HexCode.selected.color.cgColor   // 그림자 색
        self.shadowOffset = CGSize(width: 0, height: 1)     // 밑면 그림자 크기
        self.shadowOpacity = 0.9                            // 불투명도 (0 ~ 1)
        self.shadowRadius = 2                               // 흐려지는 반경
    }
    
    func createShadow(size: CGSize) {
        let currnetSize = size
        let currnetRect = CGRect(origin: .zero, size: currnetSize)
        let path = UIBezierPath(roundedRect: currnetRect, cornerRadius: cornerRadius)
        
        self.shadowPath = path.cgPath
        self.shadowColor = HexCode.selected.color.cgColor   // 그림자 색
        self.shadowOffset = CGSize(width: 0, height: 1)     // 밑면 그림자 크기
        self.shadowOpacity = 0.9                            // 불투명도 (0 ~ 1)
        self.shadowRadius = 2                               // 흐려지는 반경
    }
}
