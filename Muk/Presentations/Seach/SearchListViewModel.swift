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
    
    func viewModelAtIndex(_ index: Int) -> SearchViewModel {
        let document = documents[index]
        return SearchViewModel(document: document)
    }
    
    // API 통신 중, documents 데이터를 업데이트
    private func updateDocuments(_ documents: [LDocument]) {
        self.documents = documents
    }
    
    func getLocation(name: String, completion: @escaping () -> Void) {
        guard let currentLoaction = currentLoaction else {
            // 위치 정보가 없을 때, distance 없이 데이터 얻음
            Service.getLocation(name: name) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let location):
                    self.updateDocuments(location.documents)
                    completion()
                case .failure(let error):
                    print(error)
                }
            }
            return
        }
        
        // 위치 정보가 있을 때, distance 정보를 포함한 데이터를 얻음
        Service.getLocationWithDistance(name: name,
                                        lat: currentLoaction.latitude,
                                        lng: currentLoaction.longitude) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let location):
                self.updateDocuments(location.documents)
                completion()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func goNextVC(_ index: Int, fromCurrentVC: UIViewController) {
        let navVC = fromCurrentVC.navigationController
        
        let searchVM = viewModelAtIndex(index)
        let searchMapVM = SearchMapViewModel(searchViewModel: searchVM)
        let searchMapVC = SearchMapViewController(viewModel: searchMapVM)
        
        navVC?.show(searchMapVC, sender: nil)
    }
}

struct SearchViewModel {
    
    private(set) var document: LDocument
    
    init(document: LDocument) {
        self.document = document
    }
}
