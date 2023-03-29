//
//  UIImage.swift
//  Muk
//
//  Created by JINSEOK on 2023/03/15.
//

import UIKit

extension UIImage {
    
    /// 이미지의 틴트 색 변경을 위한 설정
    ///
    /// - Parameter named: 사용할 이미지 이름
    /// - Returns: alwaysTemplate 허용한  UIImage
    static func imageWithRenderingModeAlwaysTemplate(named: String) -> UIImage? {
        let image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
        return image
    }
    
    /// 불러온 이미지 사이즈 변경 (Compact 버전)
    /// - Parameter size: 이미지 사이즈 설정
    /// - Parameter tintColor: 틴트 컬러 설정
    /// - Returns: 재설정한 이미지
    func resized(to size: CGSize, tintColor: UIColor) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            // 적용할 tint 색상 설정
            tintColor.setFill()
            withRenderingMode(.alwaysTemplate).draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    /// 불러온 이미지 사이즈 변경 (Compact 버전)
    /// - Parameter size: 이미지 사이즈 설정
    /// - Returns: 재설정한 이미지
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    /// 불러온 이미지 사이즈 변경
    ///
    /// From : https://leechamin.tistory.com/558
    private func resized(to size: CGSize) -> UIImage? {
        // 비트맵 생성
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        // 비트맵 그래픽 배경에 이미지 다시 그리기
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        // 현재 비트맵 그래픽 배경에서 이미지 가져오기
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        // 비트맵 환경 제거
        UIGraphicsEndImageContext()
        // 크기가 조정된 이미지 반환
        return resizedImage
    }
}
