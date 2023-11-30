//
//  SearchMapViewController.swift
//  Muk
//
//  Created by JINSEOK on 2023/06/13.
//

import UIKit
import MapKit


final class SearchMapViewController: UIViewController {
    
    var viewModel: SearchMapViewModel!
    
    private var alertView: SearchMapAlertView!
    private let mapView = MKMapView()
    private let annotation = MKPointAnnotation()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    init(viewModel: SearchMapViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        mapView.delegate = self
        
        view.addSubview(mapView)
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        centerMapOnKorea()
        setupAnnotation()
        setupAlert()
    }
    
    deinit {
        print("SearchMapViewController 제거 됨")
    }
    
    // 한국을 중심으로 지도를 보여줌 (극적인 애니메이션 효과를 위해)
    private func centerMapOnKorea() {
        let center = CLLocationCoordinate2D(latitude: 36.2, longitude: 127.8)
        let span = MKCoordinateSpan(latitudeDelta: 4, longitudeDelta: 4)
        mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
    }
    
    // 검색으로 받은 주소를 기준으로 어노테이션 생성
    private func setupAnnotation() {
        annotation.coordinate = CLLocationCoordinate2D(latitude: viewModel.latitude,
                                                       longitude: viewModel.longitude)
    
        mapView.addAnnotation(annotation)
    }
    
    // 어노테이션이 생선된 위치를 중심으로 시야 영역 조절 (어노테이션이 추가 된 후 불리는 델리게이트에서 업데이트 시켜줌)
    private func focusAnnotation(latitude: Double, longitude: Double) {
        // 알람참이 떠야 하므로 살짝 중심 지점을 위로 올려줌
        let center = CLLocationCoordinate2D(latitude: latitude - 0.0002, longitude: longitude)
        let region = MKCoordinateRegion(center: center,
                                        latitudinalMeters: 100,
                                        longitudinalMeters: 100)
        
        mapView.setRegion(region, animated: true)
    }
    
    private func setupAlert() {
        self.alertView = SearchMapAlertView(title: viewModel.placaeName,
                                            messege: viewModel.addressName)
        alertView.delegate = self

        self.mapView.addSubview(alertView)
        alertView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    
        // 그림자 크기를 구하기 위해 드로윙 사이클을 강제로 업데이트
        self.view.layoutIfNeeded()
        let baseViewShadowPathSize = alertView.baseView.bounds.size
        alertView.baseView.layer.createShadow(size: baseViewShadowPathSize)
    }
}

// MARK: - MKMapViewDelegate

extension SearchMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        self.focusAnnotation(latitude: viewModel.latitude,
                             longitude: viewModel.longitude)
    }
}


// MARK: - SearchMapAlertView 델리게이트

extension SearchMapViewController: SearchMapAlertViewDelegate {
    
    func buttonTapped(_ view: SearchMapAlertView, action: AlertButtonAction) {
        switch action {
        case .done:
            let diaryVC = DiaryViewController()
            let coordinate = CLLocationCoordinate2D(latitude: viewModel.latitude,
                                                    longitude: viewModel.longitude)
            diaryVC.viewModel.transferLocationInfo(place: viewModel.placaeName,
                                                               address: viewModel.addressName,
                                                               coordinate: coordinate)
            
            // 주소 텍스트 필드 수정 금지
            diaryVC.textFieldIsUserInteraction(enable: false)
            
            diaryVC.modalPresentationStyle = .fullScreen
            self.present(diaryVC, animated: true)
            // 만약, popToRootViewController를 먼저 사용하게 된다면, 다크모드가 활성화 되서 문제가 발생.
            self.navigationController?.popToRootViewController(animated: false)
            
        case .cancel:
            self.navigationController?.popViewController(animated: true)
        }
    }
}
