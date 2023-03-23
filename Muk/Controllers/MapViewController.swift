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
    
    let mapView = MKMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
    }
    
}

// 해야할 일
// 1. 현재 위치 받아오기
// 2. 현재 위치 버튼 만들기 (방법있는데 1. 네비게이션 아이템에 올리는 방법..., 2. 버튼 만들기)
// 3. 파이어 베이스로 해야 되나?(이건 나중에 업데이트 시키고) realm으로 데이터 저장만 하자

// MARK: - MapKit 설정들
extension MapViewController: MKMapViewDelegate {
    
    // mapview 셋팅
    func setupMapView() {
        
        mapView.delegate = self
        
        self.view.addSubview(mapView)
        
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        // 위치 설정
        // 아마 이건 처음에 위치 설정하면 그곳으로 보내줘야 할 듯
        let centerCoordinate = CLLocationCoordinate2D(latitude: 37.27543611,
                                                      longitude: 127.4432194)
        
        // 지도의 범위 (작을수록 홛개)
        let span = MKCoordinateSpan(latitudeDelta: 0.05,
                                    longitudeDelta: 0.05)
        
        // 화면 중간에 나타날 지점(centerCoordinate), 지도의 영역 설정(작을수록 영역을 확대)
        mapView.setRegion(MKCoordinateRegion(center: centerCoordinate,
                                             span: span),
                          animated: false)
        
        // 사용자 위치 보기
        mapView.showsUserLocation = true
        
        // 회전 가능 여부
        mapView.isRotateEnabled = false
        
        //mapView:didChangeUserTrackingMode:animated: 를사용해야함 (네비게이션 사용해야 됨)
        let buttonItem = MKUserTrackingBarButtonItem(mapView: mapView)
        self.navigationItem.rightBarButtonItem = buttonItem
        
       

        // 줌 가능 여부
        // mapView.zoomEnabled = false
        // 스크롤 가능 여부
        // mapView.scrollEnabled = false
        // 각도 가능 여부
        // mapView.pitchEnabled = false
        
        addCustomPin()
    }
    
    // TODO: - 함수를 재사용가능하게 만들어야 됨! 리턴 값으로 받던 아니면 그냥 수정하던 일단 생각해보자.
    // 핀 설정
    private func addCustomPin() {
        let pin = MKPointAnnotation()
        pin.coordinate = CLLocationCoordinate2D(latitude: 37.27543611,
                                                longitude: 127.4432194)
        pin.title = "음식점"
        pin.subtitle = "핫도그를 파는 곳"
        mapView.addAnnotation(pin)
    }
    
    // 커스텀 핀(어노테이션)을 구현하는 delegate 메서드
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //        guard !(annotation is MKUserLocation) else {
        //            return nil
        //        }
        
        var annotaionView = mapView.dequeueReusableAnnotationView(withIdentifier: "Custom")
        
        if annotaionView == nil {
            // 어노테이션을 생성
            annotaionView = MKAnnotationView(annotation: annotation,
                                             reuseIdentifier: "Custom")
            // 핀(어노테이션)을 클릭 시 정보(callout)창을 나오게함
            // 콜아웃 대신에 밑에다가 콜렉션 뷰를 한개 만들어서 누르면 나오게 만드는것도 좋을 듯
            // 나중에 클릭하면 이미지도 커지게 만들자.
            annotaionView?.canShowCallout = true
            
            // TODO: - 여기서 버튼을 클릭하면 정보를 바꿀 수 있게 해야겠다.
            // 그럴려면 일단 버튼을 edit 이미지로 수정 후 작업
            let button = UIButton(type: .detailDisclosure)
            
            annotaionView?.rightCalloutAccessoryView = button
            
        } else {
            annotaionView?.annotation = annotation
        }
        
        annotaionView?.image = UIImage(named: "globe.fill")
        
        return annotaionView
    }
    
    // 어노테이션의 콜아웃에 있는 버튼을 설정
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        
    }
    
    
    // 어노테이션 클릭 시
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // 애니메이션을 주자
        UIView.animate(withDuration: 0.2) {
            view.transform = CGAffineTransform(scaleX: 2, y: 2)
        }
        
        // 기본 어노테이션의 콜아웃은 별로니 아래쪽에 콜랙션뷰로 정보창을 띄우면 될 듯 (레이아웃 생각해보자)
        // 그럴려면 그 핀에 대한 정보가 필요하겠네 어떻게 불러오지?
        
    }
    
    // 어노테이션 클릭 취소 시
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
        UIView.animate(withDuration: 0.1) {
            view.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        
        // 위에서 만든 정보창도 사라지게 해야된다.
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
