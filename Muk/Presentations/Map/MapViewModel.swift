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
    
    private(set) var locationManager = LocationManager()
    private(set) var currentCoordinate: CLLocationCoordinate2D?
    
    private(set) var allAnnotaions = [CustomAnnotation]()
    private(set) var selectedAnnotation: Observable<CustomAnnotation> = Observable(CustomAnnotation())
    private(set) var mapZoomRange: Observable<Int> = Observable(500)
    private(set) var currentRegion: MKCoordinateRegion?
    
    // MARK: - Initializer
    
    init() {
        self.fetchLocation()
        self.setupNotification()
    }
}

// MARK: - Location Methods

extension MapViewModel {

    // currentCoordinate에 현재 위치주소를 담는 핸들러
    private func fetchLocation() {
        locationManager.fetchLocation { [weak self] location, error in
            guard let self = self else { return }
            
            self.currentCoordinate = location
            self.setupCurrentRegion()
        }
    }
    
    // 현재 위치를 딱 한번 요청해서 업데이트시켜 줍니다.
    func requestLocation() {
        locationManager.requestLocation()
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
    
    func startZoomRangeNotificationWithCompletion() {
        NotificationNameIs.zoomRange.startNotification { [weak self] notification in
            guard let self = self,
                  let zoomRange = notification.object as? Int else { return }
            
            self.mapZoomRange.value = zoomRange
        }
    }
    
    func stopNotification() {
        NotificationNameIs.saveButton.stopNotification()
        NotificationNameIs.deleteBtton.stopNotification()
        NotificationNameIs.zoomRange.stopNotification()
    }
    
    func loadAllAnnotations() -> [MKAnnotation] {
        return self.allAnnotaions
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
        // LazyMapSequence이기 때문에 먼저 배열로 감싸줘서 [CustomAnnotation]으로 만들어주는 작업이 필요하다.
        let annotaions = Array(databaseModels).map { CustomAnnotation(databaseModel: $0, process: .save) }
        
        self.allAnnotaions = annotaions
        
        annotaions.forEach {
            self.selectedAnnotation.value = $0
        }
    }
    
    // 처음 시작할 때, 저장된 맵 설정관련 데이터를 받아옵니다.
    private func loadUserDefault() {
        guard let zoomRange = UserDefaults.standard.value(forKey: MapZoomRange.title) as? Int else { return }
        mapZoomRange.value = zoomRange
    }
}
