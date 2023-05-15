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
    
    private var diaryModel: DiaryModel
    
    init() {
        self.diaryModel = DiaryModel()
    }
    
    // MARK: - Method
    
    // UI 데이터들을 저장!
    func configData(on view: DiaryView) {
        diaryModel.dateText = view.dateTextField.text
        diaryModel.placeName = view.placeTextField.text
        diaryModel.locationName = view.locationTextField.text
        diaryModel.detailText = view.detailTextView.text
    }
    
    // PHPickerViewController 에서 이미지를 받아 저장함
    func insertImage(image: UIImage, at index: Int) {
        diaryModel.images?.insert(image, at: index)
    }
    
    func makeEmptyImages() {
        diaryModel.images = []
    }
    
    // MapView에서 coordinate를 전달받음
    func transferCoordinate(_ coordinate: CLLocationCoordinate2D) {
        self.diaryModel.coordinate = (coordinate.latitude, coordinate.longitude)
    }
    
    func postNotificationWithModel() {
        NotificationNameIs.saveButton.postNotification(with: diaryModel)
    }
}
