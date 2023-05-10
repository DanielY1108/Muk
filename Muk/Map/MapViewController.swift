//
//  MapViewController.swift
//  Muk
//
//  Created by JINSEOK on 2023/03/13.
//

import UIKit
import SnapKit
import MapKit

final class MapViewController: UIViewController {
    
    // MARK: - Properties
    private let mapView = MKMapView()
    
    private let locationManager = CLLocationManager()
    
    private var currentCoordinate: CLLocationCoordinate2D?
    
    private var allAnnotaions: [MKAnnotation]?
    
    private var displayedAnnotations: [MKAnnotation]? {
        didSet {
            if let newAnnotations = displayedAnnotations {
                mapView.addAnnotations(newAnnotations)
            }
        }
    }
    
    // MARK: - LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
        setupCurrnetLocationButton()
        setupLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
}

// MARK: - MapViewController 설정들
extension MapViewController {
    
    // 현재 위치 버튼 생성
    private func setupCurrnetLocationButton() {
        let currentLocationButton = UIFactory.createCurrentLocationButton(size: 44)
        
        self.view.addSubview(currentLocationButton)
        
        currentLocationButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(15)
            $0.bottom.equalToSuperview().inset(120)
        }
        
        currentLocationButton.addTarget(self, action: #selector(currentLocationHandelr), for: .touchUpInside)
    }
    
    @objc func currentLocationHandelr(_ sender: UIButton) {
        print("Current Location")
        
        guard let coordinaite = currentCoordinate else {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        let region = MKCoordinateRegion(center: coordinaite,
                                        latitudinalMeters: 500,
                                        longitudinalMeters: 500)
        
        self.mapView.setRegion(region, animated: true)
    }
    
}

// MARK: - MapKit 설정 & 델리게이트

extension MapViewController: MKMapViewDelegate {
    
    // mapview 셋팅
    private func setupMapView() {
        
        mapView.delegate = self
        
        self.view.addSubview(mapView)
        
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        mapView.showsUserLocation = true
        mapView.isRotateEnabled = false
        
        registerMapAnnotationViews()
        centerMapOnKorea()
        addAnnotation()
    }
    
    // 한국 중심으로 지도를 시작
    private func centerMapOnKorea() {
        let center = CLLocationCoordinate2D(latitude: 36.2, longitude: 127.8)
        let span = MKCoordinateSpan(latitudeDelta: 4, longitudeDelta: 4)
        mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
    }
    
    // annotation 추가
    private func addAnnotation() {
        //        let annotation1 = CustomAnnotation(title: "My Home",
        //                                          coordinate: CLLocationCoordinate2D(latitude: 37.2719952,
        //                                                                             longitude: 127.4348221))
        //        annotation1.imageName = "myProfile"
        //
        //        allAnnotaions = [annotation1]
        //        displayedAnnotations = allAnnotaions
    }
    
    // 재사용을 위해 식별자 생성
    private func registerMapAnnotationViews() {
        mapView.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(CustomAnnotationView.self))
    }
    
    // 만들어 둔 식별자를 갖고 Annotation view 생성
    private func setupAnnotationView(for annotation: CustomAnnotation, on mapView: MKMapView) -> MKAnnotationView {
        return mapView.dequeueReusableAnnotationView(withIdentifier: NSStringFromClass(CustomAnnotationView.self), for: annotation)
    }
    
    // annotation view 커스터마이징
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 현재 위치 표시(점)도 일종에 어노테이션이기 때문에, 이 처리를 안하게 되면, 유저 위치 어노테이션도 변경 된다.
        guard !annotation.isKind(of: MKUserLocation.self) else { return nil }
        
        var annotationView: MKAnnotationView?
        
        if let customAnnotation = annotation as? CustomAnnotation {
            annotationView = setupAnnotationView(for: customAnnotation, on: mapView)
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // 유저 어노테이션 클릭 시 동작 안하게 만듬
        guard !(view.annotation is MKUserLocation) else {
            mapView.deselectAnnotation(view.annotation, animated: false)
            return
        }
        
        print("어노테이션이 클릭 됨")
    }
}


// MARK: - 위치 설정 & 델리게이트
extension MapViewController: CLLocationManagerDelegate {
    
    func setupLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
            debugPrint("Location Auth: Allow")
            
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            debugPrint("Location Auth: denied")
            
        default:
            print("위치 서비스를 허용하지 않음")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentCoordinate = locations[0].coordinate
    }
    
}

// MARK: - PreView 읽기
import SwiftUI

#if DEBUG
struct PreView1: PreviewProvider {
    static var previews: some View {
        // 사용할 뷰 컨트롤러를 넣어주세요
        MapViewController()
            .toPreview()
    }
}
#endif


