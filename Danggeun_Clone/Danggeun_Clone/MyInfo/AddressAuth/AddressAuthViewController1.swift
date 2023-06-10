//
//  AddressAuthViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/11/10.
//

import UIKit
import NMapsMap
import Kingfisher
import CoreLocation

class AddressAuthViewController1: UIViewController {
    
    @IBOutlet var naverMapView: NMFNaverMapView!
    @IBOutlet var locationButton: UIButton!
    @IBOutlet var indicatorView: UIActivityIndicatorView!
   
    @IBOutlet var warningLabel: UILabel!
    @IBOutlet var warningView: UIView!
    
    @IBOutlet var changeCurrentAddressView: UIView!
    @IBOutlet var completionAddressView: UIView!
    
    @IBOutlet var descriptionLabel: UILabel!

    var vcType = VCType.authAddressVC
    
    var isUpdateLocation = false
    var currentAddress = ""
    var oldAddress = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicatorView.isHidden = true
        
        naverMapView.showLocationButton = false
        naverMapView.showZoomControls = false
        
//        // 투명도 0 ~ 1 사이값
//        // 0 = 투명, 1 = 불투명
        locationButton.layer.shadowOpacity = 0.5
        locationButton.layer.shadowColor = UIColor.black.cgColor
//        // 퍼짐 정도
        locationButton.layer.shadowRadius = 5
        locationButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        locationButton.layer.cornerRadius = locationButton.frame.height / 2
        
        naverMapView.mapView.positionMode = .direction
        
        naverMapView.mapView.zoomLevel = 16
        
        fetchCurrentAddress()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let coord = LocationManager.shared.locationManager?.location?.coordinate

        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: coord?.latitude ?? 0.0, lng: coord?.longitude ?? 0.0))
        cameraUpdate.animation = .easeIn
        naverMapView.mapView.moveCamera(cameraUpdate)
    }
    
    @IBAction func tapLocationButton(_ sender: Any) {
        if isUpdateLocation {
            return
        }
        
        isUpdateLocation = true
        indicatorView.isHidden = false
        indicatorView.startAnimating()
        LocationManager.shared.locationManager?.startUpdatingLocation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            LocationManager.shared.locationManager?.stopUpdatingLocation()
        
            // 현재위치 주소 받아오기
            LocationManager.shared.getNaverCurrentLocation { area1, area2, area3, area4 in
                
            }
            
            let coord = LocationManager.shared.locationManager?.location?.coordinate
            let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: coord?.latitude ?? 0.0, lng: coord?.longitude ?? 0.0))
            cameraUpdate.animation = .easeIn
            self.naverMapView.mapView.moveCamera(cameraUpdate)
            self.isUpdateLocation = false
            self.indicatorView.isHidden = true
            self.indicatorView.stopAnimating()
        }
    }
    
    @IBAction func tapCompletionAddressButton(_ sender: Any) {
        var userData = UserModel.getUserData()
        var updateData = [String: Any]()
        
        if currentAddress == userData?.address1 { // 첫번째 동네가 현재 동네랑 같은지 확인
            userData?.selectedAddress = currentAddress
            userData?.authAddress1 = true
            updateData = ["selectedAddress": userData?.selectedAddress ?? "",
                          "authAddress1": userData?.authAddress1 ?? false]
        } else if currentAddress == userData?.address2 { // 두번째 동네가 현재 동네랑 같은지 확인
            userData?.selectedAddress = currentAddress
            userData?.authAddress2 = true
            updateData = ["selectedAddress": userData?.selectedAddress ?? "",
                          "authAddress2": userData?.authAddress2 ?? false]
        } else { // 첫번째 동네, 두번째 동네 둘다 현재 동네와 같지 안을때
            if oldAddress == userData?.address1 {
                userData?.selectedAddress = currentAddress
                userData?.address1 = currentAddress
                userData?.authAddress1 = true
                updateData = ["selectedAddress": userData?.selectedAddress ?? "",
                              "address1": userData?.address1 ?? "",
                              "authAddress1": userData?.authAddress1 ?? false]
            } else {
                userData?.selectedAddress = currentAddress
                userData?.address2 = currentAddress
                userData?.authAddress2 = true
                updateData = ["selectedAddress": userData?.selectedAddress ?? "",
                              "address2": userData?.address2 ?? "",
                              "authAddress2": userData?.authAddress2 ?? false]
            }
        }
        
//        FirebaseManager.shared.updateAddressData(userPhoneNumber: userData?.phoneNumber ?? "", data: updateData) {
//            if let userData = userData {
//                UserModel.saveUserData(userData: userData)
//            }
//            self.dismiss(animated: true)
//        }
    
        
    }

    @IBAction func tapChangeCurrentAddressButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "ChangeAddressPopup", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "changeAddressPopupVC") as? ChangeAddressPopupViewController else { return }
        vc.delegate = self
        vc.currentAddress = self.currentAddress
        self.present(vc, animated: false)
    }
    
    
    
    func fetchCurrentAddress() {
        // area1, area2, area3, area4
        LocationManager.shared.getNaverCurrentLocation { area1, area2, area3, area4 in
            let selectedAddress = (UserModel.getUserData()?.selectedAddress ?? "").components(separatedBy: " ")

            let checkArea1 = area1 == selectedAddress[0]
            let checkArea2 = area2 == selectedAddress[1]

            switch selectedAddress.count {
            case 2:
                self.currentAddress = area1 + " " + area2
                if checkArea1 && checkArea2 {
                    self.changeLayout(isCheckArea: true, currentArea: area2, selectedArea: selectedAddress[1])
                } else {
                    self.changeLayout(isCheckArea: false, currentArea: area2, selectedArea: selectedAddress[1])
                }
            case 3:
                self.currentAddress = area1 + " " + area2 + " " + area3
                let checkArea3 = area3 == selectedAddress[2]

                if checkArea1 && checkArea2 && checkArea3 {
                    self.changeLayout(isCheckArea: true, currentArea: area3, selectedArea: selectedAddress[2])
                } else {
                    self.changeLayout(isCheckArea: false, currentArea: area3, selectedArea: selectedAddress[2])
                }
            case 4:
                self.currentAddress = area1 + " " + area2 + " " + area3 + " " + area4
                let checkArea3 = area3 == selectedAddress[2]
                let checkArea4 = area4 == selectedAddress[3]

                if checkArea1 && checkArea2 && checkArea3 && checkArea4 {
                    self.changeLayout(isCheckArea: true, currentArea: area4, selectedArea: selectedAddress[3])
                } else {
                    self.changeLayout(isCheckArea: false, currentArea: area4, selectedArea: selectedAddress[3])
                }
            default:
                break
            }

        }
    }

    func changeLayout(isCheckArea: Bool, currentArea: String, selectedArea: String) {
        
        DispatchQueue.main.async {
            if isCheckArea {
                self.warningView.isHidden = true
                self.changeCurrentAddressView.isHidden = true
                self.completionAddressView.isHidden = false

                self.descriptionLabel.text = "현재 위치가 내 동네로 설정한 '\(selectedArea)'에 있습니다."
            } else {
                self.warningView.isHidden = false
                self.changeCurrentAddressView.isHidden = false
                self.completionAddressView.isHidden = true

                self.warningLabel.text = "잠깐만요! 현재 위치가 \(currentArea)이에요."
                self.warningView.backgroundColor = .red

                self.descriptionLabel.text = "현재 내 동네로 설정되어 있는 '\(selectedArea)'에서만 동네인증을 할 수 있어요.\n현재 위치를 확인해주세요."
            }
        }
    }
}

extension AddressAuthViewController1: ChangeAddressPopupViewControllerDelegate {
    func changeSelectedAddress(currentAddress: String) {
        // 내가 원래 선택한 동네 가져오기
        oldAddress = UserModel.getUserData()?.selectedAddress ?? ""
        // 변경할 현재 동네
        self.currentAddress = currentAddress
        
        changeLayout(isCheckArea: true, currentArea: currentAddress, selectedArea: currentAddress.components(separatedBy: " ").last ?? "")
    }
}
