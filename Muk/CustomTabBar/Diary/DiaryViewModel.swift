//
//  DiaryViewModel.swift
//  Muk
//
//  Created by JINSEOK on 2023/04/24.
//

import UIKit
import PhotosUI

final class DiaryViewModel {
    
    // MARK: - Properties
    
    var images: [UIImage]?
    var date: String?
    var placeName: String?
    var locationName: String?
    var detail: String?
    
    
    // MARK: - Method
    
    // 데이터들을 저장!
    func configData(in view: DiaryView) {
        date = view.dateTextField.text
        placeName = view.placeTextField.text
        locationName = view.locationTextField.text
        detail = view.detailTextView.text
    }
    
    // PHPickerViewController 에서 이미지를 받아 저장함
    func insertImage(image: UIImage, at index: Int) {
        images?.insert(image, at: index)
    }
    
    func makeEmptyImages() {
        images = []
    }

   
    
}
