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
    
    private(set) var viewModel = MapViewModel()
    
    private let mapView = MKMapView()
    
    // MARK: - LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.binding()
        // 바인딩 후, setupDatabase 작업을 해줘야 한다!
        viewModel.setupDatabase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.stopNotification()
    }
}

// MARK: - UI 설정

extension MapViewController {
    
    private func setupUI() {
        // 다크 모드
        self.overrideUserInterfaceStyle = .dark
        
        self.setupMapView()
        self.setupCurrnetLocationButton()
        
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
    
    // 버튼을 클릭하면, 아이콘이 바뀌면서 동작을 다르게 설정해 줌
    @objc func currentLocationHandelr(_ sender: UIButton) {
        print("Current Location")
        
        sender.isSelected.toggle()
        
        switch sender.isSelected {
        case true:
            changeCurrentButtonImage(sender, type: .currnetLoaction)
            // 현재 위치로 이동
            guard let currentRegion = viewModel.currentRegion else { return }
            mapView.setRegion(currentRegion, animated: true)
            
        case false:
            changeCurrentButtonImage(sender, type: .mapCenteredOnKorea)
            // 한국이 중심에 보이게 이동
            self.mapCenteredOnKorea()
        }
    }
    
    private enum CurrnetButton {
        case currnetLoaction
        case mapCenteredOnKorea
    }
    
    private func changeCurrentButtonImage(_ button: UIButton, type: CurrnetButton) {
        switch type {
        case .currnetLoaction:
            let image = UIImage(named: "currentLocation_v1")
            let resizedImage = image?.resized(to: 44 - 10,
                                              tintColor: HexCode.selected.color)
            button.setImage(resizedImage, for: .normal)
        case .mapCenteredOnKorea:
            let image = UIImage(named: "currentLocation_v2")
            let resizedImage = image?.resized(to: 44 - 15,
                                              tintColor: HexCode.selected.color)
            button.setImage(resizedImage, for: .normal)
        }
    
    }
}

// MARK: - Methods

extension MapViewController {
    
    private func binding() {
        // 어노테이션 바인딩
        viewModel.selectedAnnotation.bind { [weak self] annotation in
             guard let self = self else { return }
            // AnnotaionProcess을 갖고 각각을 다른 동작을 하게 함.
            switch annotation.process {
            case .save:
                self.mapView.addAnnotation(annotation)
            case .delete:
                self.mapView.removeAnnotation(annotation)
            default: break
            }
        }
        
        viewModel.mapType.bind { mapType in
            switch mapType {
            case MapType.standard.name:
                if #available(iOS 16.0, *) {
                    self.mapView.preferredConfiguration = MKStandardMapConfiguration()
                } else {
                    self.mapView.mapType = .standard
                }
            case MapType.satellite.name:
                if #available(iOS 16.0, *) {
                    self.mapView.preferredConfiguration = MKImageryMapConfiguration()
                } else {
                    self.mapView.mapType = .satellite
                }
            case MapType.hybrid.name:
                if #available(iOS 16.0, *) {
                    self.mapView.preferredConfiguration = MKHybridMapConfiguration()
                } else {
                    self.mapView.mapType = .hybrid
                }
            default: break
            }
        }
        
        // 현재 위치 표시 범위를 위한 바인딩 (버튼에서 Region 사용)
        viewModel.mapZoomRange.bind { [weak self] mapZoomRange in
            guard let self = self else { return }
            self.viewModel.setupCurrentRegion()
        }
    }
}


// pop 버튼 델리게이트 핸들러
extension MapViewController: CustomTabBarDelegate {
    func didSelectedPopButton(_ tabBar: CustomTabBarController, presentController: UIViewController) {
        
        switch presentController {
        case is SearchViewController:
            guard let searchVC = presentController as? SearchViewController else {
                return
            }
            
            if let currentCoordinate = viewModel.currentCoordinate {
                print("Successed send current location to searchVC")
                searchVC.searchListViewModel = SearchListViewModel(currentLoaction: currentCoordinate)
            } else {
                print("Failed to get the Current Location Coordinate - Search")
                searchVC.searchListViewModel = SearchListViewModel(documents: [])
            }
            
        case is DiaryViewController:
            guard let diaryVC = presentController as? DiaryViewController else {
                return
            }
            
            if let currentCoordinate = viewModel.currentCoordinate {
                print("Successed send current location to DiaryVC")
                // DiaryVC로 현재 위치를 전달 및 주소를 API를 통해 받아옴
                diaryVC.viewModel.transferCoordinate(currentCoordinate)
            } else {
                print("Failed to get the Current Location Coordinate - Diary")
                // TODO: - 여기서 일단 주소를 사용안할 때, 현재 위치에서 어노테이션 추가가 불가능 하니, 다시 위치를 허용하는지 여부를 물어봐야한다. 아니면 무조건 위치 허용 안하면 앱 사용 불가능하게 만들어야 됨
            }
            
        default: break
        }
    }
}

// MARK: - MKMapView 설정 & 델리게이트

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
        mapCenteredOnKorea()
    }
    
    // 한국 중심으로 지도를 시작
    private func mapCenteredOnKorea() {
        let center = CLLocationCoordinate2D(latitude: 36.3, longitude: 127.8)
        let span = MKCoordinateSpan(latitudeDelta: 4.5, longitudeDelta: 4.5)
        mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
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
            // 유저 어노테이션 클릭은 동작 안하게 만듬 (didSelect에서 반응을 무시해도 소용없다.⭐️)
            userAnnotaionView.isEnabled = false
            return userAnnotaionView
        }
        
        var annotationView: MKAnnotationView?
        
        if let customAnnotation = annotation as? CustomAnnotation {
            annotationView = setupAnnotationView(for: customAnnotation, on: mapView)
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("어노테이션이 클릭 됨")
        
        UIView.animate(withDuration: 0.3) {
            view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        print("어노테이션이 클릭 해제됨")
        
        UIView.animate(withDuration: 0.3) {
            view.transform = CGAffineTransform.identity
        }
    }
}
