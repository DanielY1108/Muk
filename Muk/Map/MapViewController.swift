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
    
    var viewModel = MapViewModel()
    
    private let mapView = MKMapView()
    
    private let locationManager = CLLocationManager()
    
    private var currentCoordinate: CLLocationCoordinate2D?
    
    private var allAnnotaions: [MKAnnotation]?
    
    private var displayedAnnotations: [MKAnnotation]? {
        didSet {
            guard let newAnnotations = displayedAnnotations else { return }
            mapView.addAnnotations(newAnnotations)
        }
    }
    
    // MARK: - LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMapView()
        setupCurrnetLocationButton()
        setupLocation()
        setupNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationNameIs.saveButton.stopNotification()
    }
    
}

// MARK: - MapViewController 설정들

extension MapViewController {
    
    private func setupUI() {
        // 커스텁 탭바의 버튼들의 델리게이트 설정 세팅
        guard let customTabBarController = tabBarController as? CustomTabBarController else { return }
        customTabBarController.customDelegate = self
    }
    
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
        
        guard let coordinate = currentCoordinate else {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
//        viewModel.setRegion(coordinate, on: self.mapView)
        // 현재위치에서 어느정도 영역으로 확대할지 보여주는 메서드 (currentLocationHandelr)
        func setRegion(_ coordinate: CLLocationCoordinate2D, on mapView: MKMapView) {
            let region = MKCoordinateRegion(center: coordinate,
                                            latitudinalMeters: 500,
                                            longitudinalMeters: 500)
            
            mapView.setRegion(region, animated: true)
        }
    
    }
    
    // DiaryVC에서 Save버튼을 클릭하면 받는 노티피케이션
    private func setupNotification() {
        NotificationNameIs.saveButton.startNotification { [weak self] notification in
            guard let self = self,
                  let model = notification.object as? DiaryModel,
                  let coordinate = model.coordinate,
                  let dateText = model.dateText else { return }
            
            let image = model.images?.first ?? UIImage(named: "emptyImage")!
            
            self.addAnnotation(coordinate: coordinate,
                               date: dateText,
                               image: image)
        }
    }
}

extension MapViewController: CustomTabBarDelegate {
    func didSelectedPopButton(_ tabBar: CustomTabBarController, presentController: UIViewController) {
        switch presentController {
        case is DiaryViewController:
            print("Send current location to DiaryVC")
            guard let diaryVC = presentController as? DiaryViewController,
                  let currentCoordinate = currentCoordinate else {
                print("Failed to get the Current Location Coordinate")
                return
            }
            // DiaryVC로 현재 위치 주소를 전달
            diaryVC.viewModel.configCoordinateData(currentCoordinate)

        default: break
            
        }
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
    }
    
    // 한국 중심으로 지도를 시작
    private func centerMapOnKorea() {
        let center = CLLocationCoordinate2D(latitude: 36.2, longitude: 127.8)
        let span = MKCoordinateSpan(latitudeDelta: 4, longitudeDelta: 4)
        mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
    }
    
    // annotation 추가
    private func addAnnotation(coordinate: (Double, Double), date: String, image: UIImage) {
        let annotation = CustomAnnotation(coordinate: coordinate,
                                          image: image)
        
        allAnnotaions = [annotation]
        displayedAnnotations = allAnnotaions
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
        guard !annotation.isKind(of: MKUserLocation.self) else {
            // 유저 핀을 가장 위쪽으로 올리는 작업 (이 작업 또는 추가되는 핀을 가장 아래로 내리면 해결 됨)
            let userAnnotaionView = MKUserLocationView(annotation: annotation,
                                                       reuseIdentifier: "UserAnnotation")
            userAnnotaionView.zPriority = .max
            return userAnnotaionView
        }
        
        var annotationView: MKAnnotationView?
        
        if let customAnnotation = annotation as? CustomAnnotation {
            annotationView = setupAnnotationView(for: customAnnotation, on: mapView)
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // 유저 어노테이션 클릭은 동작 안하게 만듬
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


