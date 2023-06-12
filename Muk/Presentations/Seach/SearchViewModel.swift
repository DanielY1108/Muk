//
//  SearchViewModel.swift
//  Muk
//
//  Created by JINSEOK on 2023/06/12.
//

import UIKit
import CoreLocation

class SearchListViewModel {
    
    private(set) var documents: [Document]
    private(set) var currentLoaction: CLLocationCoordinate2D?
    
    // 현재 위치가 없을 때, 생성자 (mapVC에서 사용)
    init(documents: [Document]) {
        self.documents = documents
    }
    
    // 현재 위치가 있을 때, 생성자 (mapVC에서 사용)
    init(currentLoaction: CLLocationCoordinate2D) {
        self.documents = []
        self.currentLoaction = currentLoaction
    }
    
    var numberOfSection: Int {
        return 1
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return documents.count
    }
    
    func documentAtIndex(_ index: Int) -> SearchViewModel {
        let document = documents[index]
        return SearchViewModel(document: document)
    }
    
    // API 통신 중, documents 데이터를 업데이트
    func updateDocuments(_ documents: [Document]) {
        self.documents = documents
    }
}

struct SearchViewModel {
    
    private let document: Document
    private(set) var placaeName: String
    private(set) var addressName: String
    private(set) var latitude: String
    private(set) var longitude: String
    private(set) var distance: String
    
    init(document: Document) {
        self.document = document
        self.placaeName = document.placeName
        self.addressName = document.addressName
        self.latitude = document.latitude
        self.longitude = document.longitude
        self.distance = document.distance
    }
}
