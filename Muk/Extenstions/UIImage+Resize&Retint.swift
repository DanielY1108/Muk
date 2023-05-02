//
//  UIImage.swift
//  Muk
//
//  Created by JINSEOK on 2023/03/15.
//

import UIKit

extension UIImage {
    
    /// 이미지의 틴트 색 변경을 위한 설정
    /// - Parameter named: 사용할 이미지 이름
    /// - Returns: alwaysTemplate 허용한  UIImage
    static func imageWithRenderingModeAlwaysTemplate(named: String) -> UIImage? {
        let image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
        return image
    }
    
    /// 이미지 틴트색 다시 그리기
    /// - Parameter tintColor: 틴트 컬러 설정
    /// - Returns: 재설정한 이미지
    func retinted(_ tintColor: UIColor) -> UIImage {
        return UIGraphicsImageRenderer(size: self.size).image { _ in
            // 적용할 tint 색상 설정
            tintColor.setFill()
            withRenderingMode(.alwaysTemplate).draw(in: CGRect(origin: .zero, size: self.size))
        }
    }
    
    /// 불러온 이미지 사이즈 변경 (Compact 버전)
    /// - Parameter size: 이미지 사이즈 설정
    /// - Parameter tintColor: 틴트 컬러 설정
    /// - Returns: 재설정한 이미지
    func resized(to size: CGFloat, tintColor: UIColor) -> UIImage {
        let imageSize = CGSize(width: size, height: size)
        return UIGraphicsImageRenderer(size: imageSize).image { _ in
            // 적용할 tint 색상 설정
            tintColor.setFill()
            withRenderingMode(.alwaysTemplate).draw(in: CGRect(origin: .zero, size: imageSize))
        }
    }
    
    /// 불러온 이미지 사이즈 변경 (Compact 버전)
    /// - Parameter size: 이미지 사이즈 설정
    /// - Returns: 재설정한 이미지
    func resized(to size: CGFloat) -> UIImage {
        let imageSize = CGSize(width: size, height: size)
        return UIGraphicsImageRenderer(size: imageSize).image { _ in
            draw(in: CGRect(origin: .zero, size: imageSize))
        }
    }
    
    static func downsampleImage(imageAt imageURL: URL, to pointSize: CGSize, scale: CGFloat = 1) -> UIImage {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions) else { return UIImage() }
        
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as [CFString : Any] as CFDictionary
        
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else { return UIImage() }
        return UIImage(cgImage: downsampledImage)
    }
}
