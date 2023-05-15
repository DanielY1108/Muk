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
    private(set) var selectedAnnotation: Observable<CustomAnnotation> = Observable(nil)
    
    // MARK: - Initializer
    
    init() {
        self.fetchLocation()
        self.startNotificationWithCompletion()
    }
    
    // MARK: - Methods
    
}
// MARK: - Location Methods

extension MapViewModel {
    
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
    
    // 현재 위치를 딱 한번 요청해서 업데이트시켜 줍니다.
    func requestLocation() {
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
    
    private func startNotificationWithCompletion() {
        // DiaryVC에서 Save버튼을 클릭하면 받는 노티피케이션 데이터를 저장한다.
        NotificationNameIs.saveButton.startNotification { [weak self] notification in
            guard let self = self,
                  let diaryViewModel = notification.object as? DiaryViewModel,
                  // FIXME: - 어짜피 위치는 항상 존재해야 하니까 옵셔널 형태가 필요없을 것 같다.
                  let coordinate = diaryViewModel.coordinate else {
                return
            }
            
            let image = diaryViewModel.images?.first ?? UIImage(named: "emptyImage")!
            
            // 어노테이션 생성 및 추가
            let annotation = CustomAnnotation(coordinate: coordinate,
                                              image: image,
                                              identifier: diaryViewModel.identifier)
            
            self.allAnnotaions.append(annotation)
            
            // 전달하는 annotaion 저장 처리
            annotation.process = .save
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
    
    func stopNotification() {
        NotificationNameIs.saveButton.stopNotification()
        NotificationNameIs.deleteBtton.stopNotification()
    }
    
    func loadAllAnnotations() -> [MKAnnotation] {
        return self.allAnnotaions
    }
}
