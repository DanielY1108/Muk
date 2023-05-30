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
    @Persisted var date: Date
    @Persisted var placeName: String?
    @Persisted var locationName: String?
    @Persisted var detailText: String?
    
    @Persisted var location: MukLocation!
    @Persisted var photoMetaData = List<MuKPhoto>()
    
    convenience init(diaryModel: DiaryModel) {
        self.init()
        
        // 이 식별자를 통해서 이미지 폴더를 불러올 것 이다.
        self.identifier = diaryModel.identifier
        self.date = diaryModel.date
        self.placeName = diaryModel.placeName
        self.locationName = diaryModel.locationName
        self.detailText = diaryModel.detailText
        
        let loaction = diaryModel.coordinate
        self.location = MukLocation()
        self.location.latitude = loaction.lat
        self.location.longitude = loaction.lon
        
        diaryModel.selectedAssetIdentifiers.forEach {
            let mukPhoto = MuKPhoto()
            mukPhoto.selectedAssetIdentifier = $0
            self.photoMetaData.append(mukPhoto)
        }
    }
}

final class MuKPhoto: EmbeddedObject {
    @Persisted var selectedAssetIdentifier: String?
    
    convenience init(selectedAssetIdentifier: String?) {
        self.init()
        self.selectedAssetIdentifier = selectedAssetIdentifier
    }
}

final class MukLocation: EmbeddedObject {
    @Persisted var latitude: Double = 37
    @Persisted var longitude: Double = 127

}
