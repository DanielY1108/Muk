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
        viewModel.binding(mapView: mapView)
        viewModel.loadDatabase()
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
    
    @objc func currentLocationHandelr(_ sender: UIButton) {
        print("Current Location")
        
        viewModel.setRegion(on: self.mapView)
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
        centerMapOnKorea()
    }
    
    // 한국 중심으로 지도를 시작
    private func centerMapOnKorea() {
        let center = CLLocationCoordinate2D(latitude: 36.2, longitude: 127.8)
        let span = MKCoordinateSpan(latitudeDelta: 4, longitudeDelta: 4)
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


