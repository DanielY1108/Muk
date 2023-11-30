//
//  SearchViewModel.swift
//  Muk
//
//  Created by JINSEOK on 2023/06/12.
//

import UIKit
import CoreLocation

final class SearchListViewModel {
    
    private(set) var documents: [LDocument]
    private(set) var currentLoaction: CLLocationCoordinate2D?
    
    // 현재 위치가 없을 때, 생성자 (mapVC에서 사용)
    init(documents: [LDocument]) {
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
    func updateDocuments(_ documents: [LDocument]) {
        self.documents = documents
    }
}

struct SearchViewModel {
    
    private(set) var document: LDocument
    
    init(document: LDocument) {
        self.document = document
    }
}
