//
//  LocationManager.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/10/08.
//

/*
 권한 설정 로직
 1. 시스템 권한 (위치서비스 on / off)
 2. on -> 요청가능 , off -> 설정 유도하기
 3. 요청 가능일때 권한 허용, 권한 거부
 
 */

import Foundation
import CoreLocation
import UIKit

// MARK: [Class or Struct] ----------
class LocationManager: NSObject, CLLocationManagerDelegate {

    // MARK: [Let Or Var] ----------
    static let shared = LocationManager()
    var locationManager: CLLocationManager?
    
    // MARK: [Override] ----------
    override init() {
        locationManager = CLLocationManager()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        super.init()
        locationManager?.delegate = self
    }
    
    // MARK: [Function] ----------
    // 시스템 권한 체크
    func checkLocationServicesEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            print(#function, "= 가능")
            let status = CLLocationManager.authorizationStatus()
            checkAuthorization(status)
        } else {
            print(#function, "= 불가능")
        }
    }
    
    // 위치 서비스 상태 체크
    func checkAuthorization(_ status: CLAuthorizationStatus) {
        switch status {
            // 선택하지 않았을때
        case .notDetermined:
            // 앱을 사용하는 동안에 대한 위치 권한 요청
            locationManager?.requestWhenInUseAuthorization()
            // 위치 접근 시작!
            locationManager?.startUpdatingLocation()
            // 권한이 없고 거부일때
        case .restricted, .denied:
            print(#function, "= DENIED, 설정으로 유도")
            // 항상 허용일때
        case .authorizedAlways:
            print(#function, "= always")
            // 앱을 사용하는 동안에만 허용일때, 한번 허용도 여기
        case .authorizedWhenInUse:
            print(#function, "= when in use")
        @unknown default:
            print(#function, "= DEFUALT")
        }
    }
   
    func getNaverCurrentLocation(completion: @escaping (String, String, String, String) -> ()) {
        
        // 인터넷 주소로 검색해서 JSON 확인
        //"https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc?X-NCP-APIGW-API-KEY-ID=7u2f0i5fne&X-NCP-APIGW-API-KEY=Q9EcTzQmLpbZjafE6fXRSgJpd4Sv1k2YvIRkI9iP&request=coordsToaddr&coords=127.0604668987265,37.050262451171875&sourcecrs=epsg:4326&output=json&orders=roadaddr,admcode" /
        
        guard let url = URL(string: "https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc?request=coordsToaddr&coords=\(locationManager?.location?.coordinate.longitude ?? 0.0 ),\(locationManager?.location?.coordinate.latitude ?? 0.0)&sourcecrs=epsg:4326&output=json&orders=roadaddr,admcode") else { return }
    
        let session = URLSession.shared
        var request = URLRequest(url: url)

        request.httpMethod = "GET"
        request.allHTTPHeaderFields = [
            "X-NCP-APIGW-API-KEY-ID": "7u2f0i5fne",
            "X-NCP-APIGW-API-KEY": "Q9EcTzQmLpbZjafE6fXRSgJpd4Sv1k2YvIRkI9iP"
        ]
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request) { (data, urlResponse, error) in
            if let error = error {
                print("주소 가져오기 실패",error)
                return
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse, httpResponse.statusCode == 200 else { return }
            
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                
                let responseData = try decoder.decode(NaverCurrentLoationModel.self, from: data)
                let area = responseData.results.first?.region
                
                completion(area?.area1.name ?? "", area?.area2.name ?? "", area?.area3.name ?? "", area?.area4.name ?? "")
                
            } catch {
                print("에러")
            }
        }
        task.resume()
    }

//    // 좌표
//    func getNaverCoordinate(address: String, completion: @escaping (String,String) -> ()) {
//        let encodeString = address.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
//        guard let url = URL(string: "https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query=\(encodeString ?? "")") else { return }
//
//        let session = URLSession.shared
//        var request = URLRequest(url: url)
//
//        request.httpMethod = "GET"
//        request.allHTTPHeaderFields = [
//            "X-NCP-APIGW-API-KEY-ID": "7u2f0i5fne",
//            "X-NCP-APIGW-API-KEY": "Q9EcTzQmLpbZjafE6fXRSgJpd4Sv1k2YvIRkI9iP"
//        ]
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        let task = session.dataTask(with: request) { data, urlResponse, error in
//            if let error = error {
//                print("좌표 정보 가져오기 실패", error)
//                return
//            }
//
//            guard let httpResponse = urlResponse as? HTTPURLResponse, httpResponse.statusCode == 200 else { return }
//            guard let data = data else { return }
//
//            do {
//                let decoder = JSONDecoder()
//                let responseData = try decoder.decode(NaverCoordinateModel.self, from: data)
//
//                completion(responseData.addresses.last?.x ?? "0.0", responseData.addresses.last?.y ?? "0.0")
//            } catch {
//                print("실패")
//            }
//        }
//        task.resume()
//    }
}

