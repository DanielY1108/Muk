//
//  MapViewModel.swift
//  Muk
//
//  Created by JINSEOK on 2023/05/10.
//

import UIKit
import MapKit
import CoreLocation

final class MapViewModel {
    
    // MARK: - Properties
    
    private(set) var currentCoordinate: CLLocationCoordinate2D?
    private(set) var currentRegion: MKCoordinateRegion?
    
    // popupView를 위한 모델 (diaryModels)
    private(set) var diaryModels = [DiaryModel]()
    
    private(set) var allAnnotaions = [CustomAnnotation]()
    private(set) var selectedAnnotation: Observable<CustomAnnotation> = Observable(CustomAnnotation())
    private(set) var mapType: Observable<String> = Observable("표준")
    private(set) var mapZoomRange: Observable<Int> = Observable(500)
    
    // MARK: - Initializer
    
    init() {
        self.requestLocationIfTutorialBoxSelected()
        self.fetchLocation()
        self.setupNotification()
    }
}

// MARK: - Location Methods

extension MapViewModel {
    
    // 튜토리얼에서 다시 보지 않음 박스를 클릭할 경우, 위치 요청 시작
    private func requestLocationIfTutorialBoxSelected() {
        let userDefaults = UserDefaults.standard
        let isCheckedCheckBox = userDefaults.bool(forKey: "tutorial")
        
        if isCheckedCheckBox {
            LocationManager.shared.requestStart()
        }
    }

    // currentCoordinate에 현재 위치주소를 담는 핸들러
    func fetchLocation() {
        LocationManager.shared.fetchLocation { [weak self] location, error in
            guard let self = self else { return }
            self.currentCoordinate = location
            self.setupCurrentRegion()
        }
    }
}

// MARK: - MKMapView Methods

extension MapViewModel {
    
    func setupCurrentRegion() {
        guard let currentCoordinate = self.currentCoordinate else { return }
        
        let currentRegion = MKCoordinateRegion(center: currentCoordinate,
                                               latitudinalMeters: CLLocationDistance(mapZoomRange.value),
                                               longitudinalMeters: CLLocationDistance(mapZoomRange.value))
        self.currentRegion = currentRegion
    }
}

// MARK: - Notification & Annotaion Methods

extension MapViewModel {
    
    private func setupNotification() {
        startNotificationWithCompletion()
        startMapTypeNotificationWithCompletion()
        startZoomRangeNotificationWithCompletion()
    }
    
    private func startNotificationWithCompletion() {
        // DiaryVC에서 Save버튼을 클릭하면 받는 노티피케이션 데이터를 저장한다.
        NotificationNameIs.saveButton.startNotification { [weak self] notification in
            guard let self = self,
                  let diaryModel = notification.object as? DiaryModel else { return }
            
            let image = diaryModel.images?.first ?? UIImage(named: "emptyImage")!
            
            // 어노테이션 생성 및 추가
            let annotation = CustomAnnotation(coordinate: diaryModel.coordinate,
                                              image: image,
                                              identifier: diaryModel.identifier,
                                              // 전달하는 annotaion 저장 처리
                                              process: .save)
            
            self.allAnnotaions.append(annotation)
            
            self.selectedAnnotation.value = annotation
                        
            self.diaryModels.append(diaryModel)
        }
        
        // ProfileVC에서 삭제 버튼을 누를 때 UUID를 전달하는 노티피케이션
        NotificationNameIs.deleteBtton.startNotification { [weak self] notification in
            guard let self = self,
                  let identifier = notification.object as? UUID else { return }
            
            guard let selectedAnnotation = self.allAnnotaions.filter({ $0.identifier == identifier }).first else {
                print("No match identifier in the Annotaions")
                return
            }
            // identifier와 같은 annotation을 삭제하고 나머지를 반납
            self.allAnnotaions.removeAll { $0.identifier == identifier }
            
            // 전달하는 annotaion 제거 처리
            selectedAnnotation.process = .delete
            
            self.selectedAnnotation.value = selectedAnnotation
        }
    }
    
    private func startMapTypeNotificationWithCompletion() {
        NotificationNameIs.mapType.startNotification { [weak self] notification in
            guard let self = self,
                  let mapType = notification.object as? String else { return }
            
            self.mapType.value = mapType
        }
    }
    
    private func startZoomRangeNotificationWithCompletion() {
        NotificationNameIs.mapZoomRange.startNotification { [weak self] notification in
            guard let self = self,
                  let zoomRange = notification.object as? Int else { return }
            
            self.mapZoomRange.value = zoomRange
        }
    }
    
    func stopNotification() {
        NotificationNameIs.saveButton.stopNotification()
        NotificationNameIs.deleteBtton.stopNotification()
        NotificationNameIs.mapZoomRange.stopNotification()
        NotificationNameIs.mapType.stopNotification()
    }
    
    func loadAllAnnotations() -> [MKAnnotation] {
        return self.allAnnotaions
    }
    
    func annotationTapped(with view: MapPopupView, annotation: CustomAnnotation) {
        guard let data = self.diaryModels.filter({ $0.identifier == annotation.identifier }).first else { return }
        
        DispatchQueue.main.async {
            view.imageView.image = annotation.image
            view.placeLabel.text = data.placeName
            view.dateLabel.text = DateFormatter.custom(date: data.date)
            view.detailLabel.text = data.detailText
        }
    }
}

// MARK: - dataBase & UserDefault

extension MapViewModel {
    
    func setupDatabase() {
        loadDatabase()
        loadUserDefault()
    }
  
    // 처음 시작할 때, 한번만 데이터베이스에 저장된 데이터를 받아옵니다.
    private func loadDatabase() {
        let databaseModels = RealmManager.shared.load(RealmModel.self)
        
        let diaryModels = Array(databaseModels.map { DiaryModel(dataBaseModel: $0) })
        self.diaryModels = diaryModels
        
        // LazyMapSequence이기 때문에 먼저 배열로 감싸줘서 [CustomAnnotation]으로 만들어주는 작업이 필요하다.
        let annotaions = Array(databaseModels).map { CustomAnnotation(databaseModel: $0, process: .save) }
        
        self.allAnnotaions = annotaions
        
        annotaions.forEach {
            self.selectedAnnotation.value = $0
        }
    }
    
    // 처음 시작할 때, 저장된 맵 설정관련 데이터를 받아옵니다.
    private func loadUserDefault() {
        if let mapType = UserDefaults.standard.value(forKey: MapType.title) as? String {
            self.mapType.value = mapType
        }
        
        if let mapZoomRange = UserDefaults.standard.value(forKey: MapZoomRange.title) as? Int {
            self.mapZoomRange.value = mapZoomRange
        }
        
    }
}
