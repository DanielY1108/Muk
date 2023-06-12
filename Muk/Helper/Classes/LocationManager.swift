//
//  LocationManager.swift
//  Muk
//
//  Created by JINSEOK on 2023/05/11.
//

import CoreLocation

final class LocationManager: NSObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    
    typealias FetchLocationCompletion = (CLLocationCoordinate2D?, Error?) -> Void
    // 동작을 담아주기 위해 클로저를 만들어 줌
    private var fetchLocationCompletion: FetchLocationCompletion?
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        // 위치관련 정보를 받기위해선 무조건 호출되어야 합니다.
        // 설정한 plist에 따라서 requestAlwaysAuthorization로도 사용이 가능합니다
        locationManager.requestWhenInUseAuthorization()
        // 위치 정확도 (여기선 배터리 상황에 따른 최적의 정확도로 설정)
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func startUpdatingLocation() {
        // 여러번 호출해도 새 이벤트가 생성되지 않으므로
        // 새로운 이벤트를 받으러면 꼭 stopUpdatingLocation을 사용해줘야 합니다.
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func requestLocation() {
        // 현재 위치를 딱 한번만 전달합니다. (그런데 뭔가 위치를 받는게 느리다.)
        locationManager.requestLocation()
    }
    
    // 현재 위치를 받아오는 있는 메서드
    func fetchLocation(completion: @escaping FetchLocationCompletion) {
        self.requestLocation()
        // completion 동작을 didFetchLocation 동작에 담는다.
        self.fetchLocationCompletion = completion
    }
}

extension LocationManager {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 사용자의 최신 위치 정보를 가져옵니다.
        guard let location = locations.first else { return }
        let coordinate = location.coordinate
        
        // coordinate 값을 갖고 저장된 동작을 실행
        self.fetchLocationCompletion?(coordinate, nil)
        // 위의 실행 후 클로저 초기화
        self.fetchLocationCompletion = nil
    }
    
    // 잠재적인 오류에 응답하기 위해서 생성
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to Fetch Location (\(error))")
        
        // 에러발생 시 저장된 값을 갖고 동작을 실행
        self.fetchLocationCompletion?(nil, error)
        // 위의 실행 후 클로저 초기화
        self.fetchLocationCompletion = nil
    }
    
    // 현재 인증 상태 확인
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways , .authorizedWhenInUse:
            print("Location Auth: Allow")
            // 인증 메세지 늦게 클릭하면 처음 업데이트 되는 데이터를 못받게 됨. (그래서 확인을 누를 때 위치를 한번 받아 줬다)
            self.startUpdatingLocation()
        case .notDetermined , .denied , .restricted:
            print("Location Auth: denied")
            self.stopUpdatingLocation()
            // TODO: - 위치 정보를 무조건 사용해야 하므로, 알람 후 설정창을 띄어준다.
        default: break
        }
    }
}
