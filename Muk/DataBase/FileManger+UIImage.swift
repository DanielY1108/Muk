//
//  FileManger.swift
//  Muk
//
//  Created by JINSEOK on 2023/05/18.
//

import UIKit

extension FileManager {
    
    static func saveImagesToDirectory(identifier: UUID, images: [UIImage]) {
        let fileManager = self.default
        // 저장할 디렉토리 경로 설정 (picturesDirectory도 존재하지만 Realm과 같은 경로에 저장하기 위해서 documentDirectory 사용함.)
        // userDomainMask: 사용자 홈 디렉토리는 사용자 관련 파일이 저장되는 곳입니다.
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        // 식별자 폴더를 관리하기 위해 images란 폴더를 만들어 줬습니다. (images 폴더 -> 식별자로 된 폴더 -> 이미지들)
        let imagesFolderDirectory = documentsDirectory.appendingPathComponent("images")
        // 식별자 폴더로 이미지들이 저장될 폴더입니다.
        let imagesDirectory = imagesFolderDirectory.appendingPathComponent("\(identifier)")
        
        do {
            // 이미지 폴더 디렉토리가 없다면 생성
            if !fileManager.fileExists(atPath: imagesFolderDirectory.path) {
                try fileManager.createDirectory(at: imagesFolderDirectory, withIntermediateDirectories: true)
            }
            if !fileManager.fileExists(atPath: imagesDirectory.path) {
                try fileManager.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
            }
            //
            // 이미지 파일을 저장
            for (index, image) in images.enumerated() {
                let fileName = "\(index)"
                let fileURL = imagesDirectory.appendingPathComponent(fileName, conformingTo: .jpeg)
                
                if let imageData = image.jpegData(compressionQuality: 1.0) {
                    try imageData.write(to: fileURL)
                    print("Image saved at: \(fileURL)")
                }
            }
        } catch {
            print("Failed to save images: \(error)")
        }
    }
    
    static func loadImageFromDirectory(with identifier: UUID) -> [UIImage]? {
        let fileManager = self.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imagesFolderDirectory = documentDirectory.appendingPathComponent("images")
        // 식별자로 만들어진 폴더까지 접근완료
        let imagesDirectory = imagesFolderDirectory.appendingPathComponent("\(identifier)")
        
        do {
            guard fileManager.fileExists(atPath: imagesDirectory.path) else {
                print("경로에 저장된 이미지가 없습니다. 경로: \(imagesDirectory.lastPathComponent)")
                return nil
            }
            // 식별자로 지정된 폴더로 접근하여 파일들을 url로 변환해준다.
            let fileURLs = try fileManager.contentsOfDirectory(at: imagesDirectory, includingPropertiesForKeys: nil)
            // image파일만 필터링하기
            let imageURLs = fileURLs.filter { $0.pathExtension.lowercased() == "jpeg" }
            // 이미지로 변환
            let images = imageURLs.compactMap { UIImage(contentsOfFile: $0.path) }
            
            print("Succeed load image at path: \(imagesDirectory.lastPathComponent)")
            return images

        } catch {
            print("Failed to read file: \(error)")
        }
        return nil
    }
    
    static func deleteImageFromDirectory(with identifier: UUID) {
        let fileManager = self.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imagesFolderDirectory = documentDirectory.appendingPathComponent("images")
        
        let imagesDirectory = imagesFolderDirectory.appendingPathComponent("\(identifier)")

        do {
            try fileManager.removeItem(at: imagesDirectory)
            print("Succeed delete image folder at path: \(imagesDirectory.lastPathComponent)")
        } catch {
            print("Failed to delete image \(error)")
        }
    }
}
