//
//  DiaryViewModel.swift
//  Muk
//
//  Created by JINSEOK on 2023/04/24.
//

import UIKit
import PhotosUI

// ProfileVC의 UICollectionViewDiffableDataSource에 사용을 위해 hasable을 사용
final class DiaryViewModel: Hashable {
    
    static func == (lhs: DiaryViewModel, rhs: DiaryViewModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    // MARK: - Properties
    
    private(set) var identifier = UUID()
    private(set) var images: [UIImage]?
    private(set) var dateText: String?
    private(set) var placeName: String?
    private(set) var locationName: String?
    private(set) var detailText: String?
    private(set) var coordinate: (Double, Double)?
    
    // MARK: - Method
    
    // UI 데이터들을 저장!
    func configData(on view: DiaryView) {
        dateText = view.dateTextField.text
        placeName = view.placeTextField.text
        locationName = view.locationTextField.text
        detailText = view.detailTextView.text
    }
    
    // PHPickerViewController 에서 이미지를 받아 저장함
    func insertImage(image: UIImage, at index: Int) {
        images?.insert(image, at: index)
    }
    
    func makeEmptyImages() {
        images = []
    }
    
    // MapView에서 coordinate를 전달받음
    func transferCoordinate(_ coordinate: CLLocationCoordinate2D) {
        self.coordinate = (coordinate.latitude, coordinate.longitude)
    }
    
    func postNotification() {
        NotificationNameIs.saveButton.postNotification(with: self)
    }
}
