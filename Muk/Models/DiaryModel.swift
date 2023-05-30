//
//  DiaryModel.swift
//  Muk
//
//  Created by JINSEOK on 2023/04/24.
//

import UIKit
import RealmSwift

struct DiaryModel: Hashable {
    var identifier = UUID()
    var images: [UIImage]?
    var date: Date
    var placeName: String?
    var locationName: String?
    var detailText: String?
    var coordinate: (lat: Double, lon: Double)
    
    var selectedAssetIdentifiers: [String]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: DiaryModel, rhs: DiaryModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    // 바인딩 기본 값
    init() {
        self.date = Date()
        self.coordinate = (37, 127)
        self.detailText = "내용을 입력해주세요."
        self.selectedAssetIdentifiers = []
    }
    
    init(dataBaseModel: RealmModel) {
        self.identifier = dataBaseModel.identifier
        self.date = dataBaseModel.date
        self.placeName = dataBaseModel.placeName
        self.locationName = dataBaseModel.locationName
        self.detailText = dataBaseModel.detailText
        self.coordinate = (dataBaseModel.location.latitude,
                           dataBaseModel.location.longitude)
        
        let images = FileManager.loadImageFromDirectory(with: dataBaseModel.identifier)
        self.images = images
    
        var selectedAssetIdentifiers = [String]()
        dataBaseModel.photoMetaData.forEach {
            selectedAssetIdentifiers.append($0.selectedAssetIdentifier ?? "")
        }
        self.selectedAssetIdentifiers = selectedAssetIdentifiers
    }
}
