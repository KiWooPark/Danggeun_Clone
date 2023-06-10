//
//  AddressAuthViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/02/17.
//

import UIKit
import NMapsMap
import CoreLocation
import FirebaseFirestore

// MARK: [Class or Struct] ----------
class AddressAuthViewController: UIViewController {

    // MARK: [@IBOutlet] ----------
    @IBOutlet var naverMapView: NMFNaverMapView!
    @IBOutlet var locationButton: UIButton!
    @IBOutlet var indicatorView: UIActivityIndicatorView!
   
    @IBOutlet var warningLabel: UILabel!
    @IBOutlet var warningView: UIView!
    
    @IBOutlet var changeCurrentAddressView: UIView!
    @IBOutlet var completedView: UIView!
    
    @IBOutlet var changeCurrentAddressButton: UIButton!
    @IBOutlet var completedButton: UIButton!
    
    @IBOutlet var descriptionLabel: UILabel!
    
    // MARK: [Let Or Var] ----------
    var currentAddress = ""
    var isUpdateLocation = false
    
    var userData = UserModel.getUserData()
    
    // MARK: [Override] ----------
    override func viewDidLoad() {
        super.viewDidLoad()

        configNaverMapLayout()
        
        let appearance = UINavigationBarAppearance()
        appearance.setBackIndicatorImage(UIImage(named: "backButton"), transitionMaskImage: UIImage(named: "backButton"))
        appearance.backgroundColor = .white
        self.navigationItem.standardAppearance = appearance
        self.navigationItem.scrollEdgeAppearance = appearance
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let coord = LocationManager.shared.locationManager?.location?.coordinate

        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: coord?.latitude ?? 0.0, lng: coord?.longitude ?? 0.0))
        cameraUpdate.animation = .easeIn
        naverMapView.mapView.moveCamera(cameraUpdate)
    }
    
    // MARK: [@IBAction] ----------
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
        
            let coord = LocationManager.shared.locationManager?.location?.coordinate
            let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: coord?.latitude ?? 0.0, lng: coord?.longitude ?? 0.0))
            cameraUpdate.animation = .easeIn
            self.naverMapView.mapView.moveCamera(cameraUpdate)
            self.isUpdateLocation = false
            self.indicatorView.isHidden = true
            self.indicatorView.stopAnimating()
        }
    }
    
    @IBAction func tapChangeCurrentAddressButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "ChangeAddressPopup", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "changeAddressPopupVC") as? ChangeAddressPopupViewController else { return }
        vc.delegate = self
        vc.currentAddress = self.currentAddress
        self.present(vc, animated: false)
    }
    
    @IBAction func tapCompletedButton(_ sender: Any) {
        userData?.selectedAddress = currentAddress
        
        if userData?.address1 == currentAddress {
            userData?.authAddress1 = true
            Firestore.firestore().collection("유저정보").document(userData?.phoneNumber ?? "").updateData(["authAddress1": true])
        } else if userData?.address2 == "" {
            userData?.address2 = currentAddress
            userData?.authAddress2 = true
            Firestore.firestore().collection("유저정보").document(userData?.phoneNumber ?? "").updateData(["authAddress2": true])
        }
        
        UserModel.saveUserData(userData: userData)
        
        NotificationCenter.default.post(name: .reloadMainViewProducts, object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    // MARK: [Function] ----------
    func configNaverMapLayout() {
        indicatorView.isHidden = true
        
        naverMapView.showLocationButton = false
        naverMapView.showZoomControls = false
        
        locationButton.layer.shadowOpacity = 0.5
        locationButton.layer.shadowColor = UIColor.black.cgColor
        
        locationButton.layer.shadowRadius = 5
        locationButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        locationButton.layer.cornerRadius = locationButton.frame.height / 2
        
        naverMapView.mapView.positionMode = .direction
        naverMapView.mapView.zoomLevel = 16

        fetchCurrentAddress()
        
        changeCurrentAddressButton.layer.cornerRadius = 5
        changeCurrentAddressButton.layer.borderWidth = 1
        changeCurrentAddressButton.layer.borderColor = UIColor.systemGray5.cgColor
        
        completedButton.layer.cornerRadius = 5
    }
    
    func fetchCurrentAddress() {
        
        LocationManager.shared.getNaverCurrentLocation { area1, area2, area3, area4 in
            
            let selectedAddress = self.userData?.selectedAddress.components(separatedBy: " ") ?? []
            
            switch selectedAddress.count {
            case 2:
                self.currentAddress = area1 + " " + area2
                if selectedAddress[0] == area1 && selectedAddress[1] == area2 {
                    self.changeLayout(isCheckArea: true, currentArea: area2, selectedArea: selectedAddress[1])
                } else {
                    self.changeLayout(isCheckArea: false, currentArea: area2, selectedArea: selectedAddress[1])
                }
            case 3:
                self.currentAddress = area1 + " " + area2 + " " + area3
                if selectedAddress[0] == area1 && selectedAddress[1] == area2 && selectedAddress[2] == area3 {
                    self.changeLayout(isCheckArea: true, currentArea: area3, selectedArea: selectedAddress[2])
                } else {
                    self.changeLayout(isCheckArea: false, currentArea: area3, selectedArea: selectedAddress[2])
                }
            case 4:
                self.currentAddress = area1 + " " + area2 + " " + area3 + " " + area4
                if selectedAddress[0] == area1 && selectedAddress[1] == area2 && selectedAddress[2] == area3 && selectedAddress[3] == area4 {
                    self.changeLayout(isCheckArea: true, currentArea: area4, selectedArea: selectedAddress[3])
                } else {
                    self.changeLayout(isCheckArea: false, currentArea: area4, selectedArea: selectedAddress[3])
                }
            default:
                print("123123")
            }
        }
    }
    
    func changeLayout(isCheckArea: Bool, currentArea: String, selectedArea: String) {
        
        DispatchQueue.main.async {
            if isCheckArea {
                self.warningView.isHidden = true
                self.changeCurrentAddressView.isHidden = true
                self.completedView.isHidden = false

                self.descriptionLabel.text = "현재 위치가 내 동네로 설정한 '\(selectedArea)'에 있습니다."
            } else {
                self.warningView.isHidden = false
                self.changeCurrentAddressView.isHidden = false
                self.completedView.isHidden = true

                self.warningLabel.text = "잠깐만요! 현재 위치가 \(currentArea)이에요."
                self.warningView.backgroundColor = .red

                self.descriptionLabel.text = "현재 내 동네로 설정되어 있는 '\(selectedArea)'에서만 동네인증을 할 수 있어요.\n현재 위치를 확인해주세요."
            }
        }
    }
}

// MARK: [Delegate] ----------
extension AddressAuthViewController: ChangeAddressPopupViewControllerDelegate {
    func changeSelectedAddress(currentAddress: String) {
        
        // 변경할 현재 동네
        self.currentAddress = currentAddress
        
        changeLayout(isCheckArea: true, currentArea: currentAddress, selectedArea: currentAddress.components(separatedBy: " ").last ?? "")
    }
}
