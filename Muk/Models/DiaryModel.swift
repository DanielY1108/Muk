//
//  DiaryModel.swift
//  Muk
//
//  Created by JINSEOK on 2023/04/24.
//

import UIKit

struct DiaryModel: Hashable {
    let identifier = UUID()
    let images: [UIImage]?
    let date: String?
    let placeName: String?
    let locationName: String?
    let detail: String?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: DiaryModel, rhs: DiaryModel) -> Bool {
          return lhs.identifier == rhs.identifier
      }
    
    init?(_ viewModel: DiaryViewModel) {
        self.images = viewModel.images
        self.date = viewModel.date
        self.placeName = viewModel.placeName
        self.locationName = viewModel.locationName
        self.detail = viewModel.detail
    }
}
