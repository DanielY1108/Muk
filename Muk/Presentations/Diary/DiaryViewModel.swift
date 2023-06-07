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
    
    let datePicker = UIDatePicker()
    
    var diaryModel: Observable<DiaryModel> = Observable(DiaryModel())
    
    var selectedAssetIdentifiers: [String]?
    
    // MARK: - Method
    
    // PHPickerViewController 에서 이미지를 받아 모델에 저장함
    func insertImage(image: UIImage, at index: Int) {
        diaryModel.value.images?.insert(image, at: index)
    }
    
    func makeEmptyImages() {
        diaryModel.value.images = []
    }
    
    // MapView에서 coordinate(위치)를 전달받음
    func transferCoordinate(_ coordinate: CLLocationCoordinate2D) {
        self.diaryModel.value.coordinate = (coordinate.latitude, coordinate.longitude)
    }
    
    func postNotificationWithModel() {
        NotificationNameIs.saveButton.postNotification(with: diaryModel.value)
    }
    
    func saveSelectedAssetIdentifierWhenEditing() {
        self.selectedAssetIdentifiers = diaryModel.value.selectedAssetIdentifiers
    }
}

extension DiaryViewModel {
    // Realm과 FileManager의 데이터 베이스에 저장
    func saveToDatabase() {
        // Realm으로 데이터 베이스에 저장
        let databaseModel = RealmModel(diaryModel: diaryModel.value)
        RealmManager.shared.write(databaseModel)
        
        // FileManager로 이미지 저장
        guard let images = diaryModel.value.images else { return }
        FileManager.saveImagesToDirectory(identifier: databaseModel.identifier, images: images)
    }
    
    func loadImagesFromDatabase() -> [UIImage]? {
        let cellIdentifier = diaryModel.value.identifier
        guard let images = FileManager.loadImageFromDirectory(with: cellIdentifier) else { return nil }
        return images
    }
}
