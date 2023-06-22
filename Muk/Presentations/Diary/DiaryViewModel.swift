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
    
    // SearchMapViewController에서 위치 및 주소를 전달 받음
    func transferLocationInfo(place: String, address: String, coordinate: CLLocationCoordinate2D) {
        self.diaryModel.value.coordinate = (coordinate.latitude, coordinate.longitude)
        self.diaryModel.value.placeName = place
        self.diaryModel.value.addressName = address
    }
    
    func postNotificationWithModel(_ notificationName: NotificationNameIs) {
        switch notificationName {
        case .saveButton:
            NotificationNameIs.saveButton.postNotification(with: diaryModel.value)
        case .editButton:
            NotificationNameIs.editButton.postNotification(with: diaryModel.value)
        default: break
        }
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
    
    func editDatabase() {
        let databaseModel = RealmModel(diaryModel: diaryModel.value)
        RealmManager.shared.update(databaseModel)
        
        // FileManager로 이미지 저장 및 수정
        guard let images = diaryModel.value.images else { return }
        FileManager.updateImageFromDirectory(with: databaseModel.identifier, images: images)
    }
}
