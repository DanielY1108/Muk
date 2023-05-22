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
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: DiaryModel, rhs: DiaryModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    init() {
        self.date = Date()
        self.coordinate = (37, 127)
    }
    
    init(dataBaseModel: RealmModel) {
        self.identifier = dataBaseModel.identifier
        self.date = dataBaseModel.date
        self.placeName = dataBaseModel.placeName
        self.locationName = dataBaseModel.locationName
        self.detailText = dataBaseModel.detailText
        self.coordinate = (dataBaseModel.latitude, dataBaseModel.longitude)
        
        let images = FileManager.loadImageToDirectory(with: dataBaseModel.identifier)
        self.images = images
    }
}
