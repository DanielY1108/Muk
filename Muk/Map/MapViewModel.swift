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
    
    private(set) var allAnnotaions: Observable<[CustomAnnotation]> = Observable([])
    
    // MARK: - Initializer
    
    init() {
        self.fetchLocation()
        self.setupNotification()
    }
    
    // MARK: - Methods
    
    // currentCoordinate에 현재 위치주소를 담는 핸들러
    private func fetchLocation() {
        locationManager.fetchLocation { [weak self] location, error in
            guard let self = self else { return }
            self.currentCoordinate = location
        }
    }
    
    func loadCurrentCoordinate() -> CLLocationCoordinate2D? {
        return self.currentCoordinate
    }
    
    func loadAllAnnotations() -> [MKAnnotation] {
        return self.allAnnotaions.value ?? []
    }
    
    func requestLocation() {
        // 현재 위치를 딱 한번만 전달합니다.
        locationManager.requestLocation()
    }
}

// MARK: - MKMapView Methods

extension MapViewModel {
    
    // 현재위치에서 어느정도 영역으로 확대할지 보여주는 메서드 (currentLocationHandelr)
    func setRegion(on mapView: MKMapView) {
        guard let coordinate = currentCoordinate else {
            locationManager.requestLocation()
            return
        }
        
        let region = MKCoordinateRegion(center: coordinate,
                                        latitudinalMeters: 500,
                                        longitudinalMeters: 500)
        
        mapView.setRegion(region, animated: true)
    }
}

// MARK: - Notification & Annotaion Methods

extension MapViewModel {
    // DiaryVC에서 Save버튼을 클릭하면 받는 노티피케이션 데이터를 저장한다.
    private func setupNotification() {
        NotificationNameIs.saveButton.startNotification { [weak self] notification in
            guard let self = self,
                  let diaryViewModel = notification.object as? DiaryViewModel,
                  let coordinate = diaryViewModel.coordinate else {
                return
            }
            
            let image = diaryViewModel.images?.first ?? UIImage(named: "emptyImage")!
            
            // 어노테이션 생성 및 추가
            let annotation = CustomAnnotation(coordinate: coordinate, image: image)
            allAnnotaions.value?.append(annotation)
        }
    }
    
    func stopNotification() {
        NotificationNameIs.saveButton.stopNotification()
    }
}
