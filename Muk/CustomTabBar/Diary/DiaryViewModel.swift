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
        diaryModel.date = view.datePicker.date
        diaryModel.placeName = view.placeTextField.text
        diaryModel.locationName = view.locationTextField.text
        diaryModel.detailText = view.detailTextView.text
    }
    
    // PHPickerViewController 에서 이미지를 받아 모델에 저장함
    func insertImage(image: UIImage, at index: Int) {
        diaryModel.images?.insert(image, at: index)
    }
    
    func makeEmptyImages() {
        diaryModel.images = []
    }
    
    // MapView에서 coordinate(위치)를 전달받음
    func transferCoordinate(_ coordinate: CLLocationCoordinate2D) {
        self.diaryModel.coordinate = (coordinate.latitude, coordinate.longitude)
    }
    
    func postNotificationWithModel() {
        NotificationNameIs.saveButton.postNotification(with: diaryModel)
    }
    
    // Realm과 FileManager의 데이터 베이스에 저장
    func saveToDatabase() {
        // Realm으로 데이터 베이스에 저장
        let databaseModel = RealmModel(diaryModel: diaryModel)
        RealmManager.shared.write(databaseModel)
        
        // FileManager로 이미지 저장
        guard let images = diaryModel.images else { return }
        FileManager.saveImagesToDirectory(identifier: databaseModel.identifier, images: images)
    }
}
