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
    
    private let mapView = MKMapView()
    private let annotation = MKPointAnnotation()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
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
        let alert = UIAlertController(title: viewModel.placaeName,
                                      message: viewModel.addressName,
                                      preferredStyle: .actionSheet)
        let nextButton = UIAlertAction(title: "여기가 맞아요!", style: .default) { action in
            
        }
        
        let closeButton = UIAlertAction(title: "여기가 아니에요.", style: .cancel) { action in
            self.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(nextButton)
        alert.addAction(closeButton)
        present(alert, animated: true)
    }
}

extension SearchMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        self.focusAnnotation(latitude: viewModel.latitude,
                             longitude: viewModel.longitude)
        
        
    }
}
