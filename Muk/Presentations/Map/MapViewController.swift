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
    
    private let popupView = MapPopupView()
    
    private var selectedAnnotationView: MKAnnotationView?
    
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
        self.setupPopupView()
        
        // 커스텁 탭바의 버튼들의 델리게이트 설정 세팅
        guard let customTabBarController = tabBarController as? CustomTabBarController else { return }
        customTabBarController.customTabBarDelegate = self
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
        
        // 위치 권한 허용됐을 때, 버튼의 기등들을 실행 (이미지 변경, 확대)
        whenAuthorizationStatusAllowed {
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
                mapCenteredOnKorea()
            }
        }
    }
    
    // popupView를 미리 로드시켜둔다. 현재 레이아웃은 화면 밖에 위치
    private func setupPopupView() {
        self.view.addSubview(popupView)
        self.popupView.delegate = self
        popupView.initialSetupLayout(view)
    }
    
    private func whenAuthorizationStatusAllowed(action completion: () -> Void) {
        
        switch LocationManager.shared.authorizationStatus {
        case .notDetermined, .denied, .restricted:
            self.presentAppSettingsAlert()
        default:
            viewModel.fetchLocation()
            completion()
        }
    }
    
    private func presentAppSettingsAlert() {
        let alertController = UIAlertController(
            title: "위치 접근 요청",
            message: "위치 정보를 얻을 수 없습니다. 위치 권한을 '항상 허용'으로 변경해 주세요.",
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: "설정창 이동", style: .default, handler: goToAppSettings)
        alertController.addAction(action)
        
        self.present(alertController, animated: true)
    }
    
    private func goToAppSettings(_ sender: UIAlertAction) {
        guard let settingURL = URL(string: UIApplication.openSettingsURLString) else { return }
        
        if UIApplication.shared.canOpenURL(settingURL) {
            UIApplication.shared.open(settingURL)
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
                    let config = MKStandardMapConfiguration(elevationStyle: .realistic)
                    self.mapView.preferredConfiguration = config
                } else {
                    self.mapView.mapType = .standard
                }
            case MapType.satellite.name:
                if #available(iOS 16.0, *) {
                    let config = MKImageryMapConfiguration(elevationStyle: .realistic)
                    self.mapView.preferredConfiguration = config
                } else {
                    self.mapView.mapType = .satelliteFlyover
                }
            case MapType.hybrid.name:
                if #available(iOS 16.0, *) {
                    let config = MKHybridMapConfiguration(elevationStyle: .realistic)
                    self.mapView.preferredConfiguration = config
                } else {
                    self.mapView.mapType = .hybridFlyover
                    
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let customTabBarController = tabBarController as? CustomTabBarController else { return }
        customTabBarController.middleButtonAnimationEnd()
    }
}

// 탭바 델리게이트 핸들러
extension MapViewController: CustomTabBarDelegate {
    func didSelectTabBarButtons(_ tabBar: CustomTabBarController) {
        guard let annotationView = selectedAnnotationView else { return }
        mapView(mapView, didDeselect: annotationView)
    }
    
    // 데이터 전달
    func didSelectPopButton(_ tabBar: CustomTabBarController, presentController: UIViewController) {
        
        switch presentController {
        case is SearchViewController:
            guard let searchVC = presentController as? SearchViewController else {
                return
            }
            
            if let currentCoordinate = viewModel.currentCoordinate {
                print("Successed send current location to searchVC")
                searchVC.viewModels = SearchListViewModel(currentLoaction: currentCoordinate)
            } else {
                print("Failed to get the Current Location Coordinate - Search")
                searchVC.viewModels = SearchListViewModel(documents: [])
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
                presentAppSettingsAlert()
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
        selectedAnnotationView = view

        showPopView(view)
        
        // popupView로 데이터 바이딩
        guard let customAnnotaion = view.annotation as? CustomAnnotation else { return }
        viewModel.annotationTapped(with: self.popupView, annotation: customAnnotaion)
        viewModel.updateModelIndex(annotaion: customAnnotaion)
    }
    
    
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        print("어노테이션이 클릭 해제됨")
        selectedAnnotationView = nil

        hidePopView(view)
    }
    
    private func showPopView(_ annotationView: UIView) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            annotationView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.popupView.showPopupView()
        }
    }
    
    private func hidePopView(_ annotationView: UIView) {
        mapView.deselectAnnotation(nil, animated: true)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            annotationView.transform = CGAffineTransform.identity
            self.popupView.hidePopupView()
        }
    }
}

extension MapViewController: MapPopupViewDelegate {
    func tappedGoProfileButton() {
        mapView.deselectAnnotation(nil, animated: true)
        
        viewModel.goToNextVC(currnetVC: self)
    }
}

// MARK: - Helper

fileprivate enum CurrnetButton {
    case currnetLoaction
    case mapCenteredOnKorea
}

fileprivate func changeCurrentButtonImage(_ button: UIButton, type: CurrnetButton) {
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
