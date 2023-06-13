//
//  SearchMapViewModel.swift
//  Muk
//
//  Created by JINSEOK on 2023/06/13.
//

import Foundation

struct SearchMapViewModel {
    
    private var documnet: Document
        
    init(searchViewModel: SearchViewModel) {
        self.documnet = searchViewModel.document
    }
    
    var placaeName: String {
        return documnet.placeName
    }
    
    var addressName: String {
        return documnet.addressName
    }
    
    var latitude: Double {
        return Double(documnet.latitude) ?? 0
    }
    
    var longitude: Double {
        return Double(documnet.longitude) ?? 0
    }
    
}
