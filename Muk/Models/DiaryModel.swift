//
//  DiaryModel.swift
//  Muk
//
//  Created by JINSEOK on 2023/04/24.
//

import UIKit

struct DiaryModel: Hashable {
    let identifier = UUID()
    var images: [UIImage]?
    var dateText: String?
    var placeName: String?
    var locationName: String?
    var detailText: String?
    var coordinate: (Double, Double)?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: DiaryModel, rhs: DiaryModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    init() {
        self.images = nil
        self.dateText = nil
        self.placeName = nil
        self.locationName = nil
        self.detailText = nil
        self.coordinate = nil
    }
}
