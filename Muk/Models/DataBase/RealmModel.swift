//
//  RealmModel.swift
//  Muk
//
//  Created by JINSEOK on 2023/05/15.
//

import Foundation
import RealmSwift

// Object은 hashable로 동작합니다.
final class RealmModel: Object {
    @Persisted(primaryKey: true) var identifier: UUID
    @Persisted var dateText: String?
    @Persisted var placeName: String?
    @Persisted var locationName: String?
    @Persisted var detailText: String?
    
    @Persisted var latitude: Double
    @Persisted var longitude: Double
    
    convenience init(diaryModel: DiaryModel) {
        self.init()
        
        // 이 식별자를 통해서 이미지 폴더를 불러올 것 이다.
        self.identifier = diaryModel.identifier
        self.dateText = diaryModel.dateText
        self.placeName = diaryModel.placeName
        self.locationName = diaryModel.locationName
        self.detailText = diaryModel.detailText
        self.latitude = diaryModel.coordinate.lat
        self.longitude = diaryModel.coordinate.lon
    }
}
