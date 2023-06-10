////
////  SettingAddressViewController.swift
////  Danggeun_Clone
////
////  Created by PKW on 2022/09/19.
////
//
//import UIKit
//import FirebaseFirestore
//
//class SettingAddressViewController: UIViewController, UIGestureRecognizerDelegate {
//   
//    @IBOutlet var emptySecondAddressButton: UIButton!
//    
//    @IBOutlet var firstAddressView: UIView!
//    @IBOutlet var firstAddressLabel: UILabel!
//    
//    @IBOutlet var secondAddressView: UIView!
//    @IBOutlet var secondAddressLabel: UILabel!
//    
//    @IBOutlet var deleteFirstAddressButton: UIButton!
//    @IBOutlet var deleteSecondAddressButton: UIButton!
//    
//    var userData: UserModel?
//    weak var delegate: MyAddressPopupViewControllerDelegate?
//    
//    var selectedAddress = ""
//    var address1 = ""
//    var authAddress1 = false
//    var address2 = ""
//    var authAddress2 = false
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    
//        userData = UserModel.getUserData()
//        
//        selectedAddress = userData?.selectedAddress ?? ""
//        address1 = userData?.address1 ?? ""
//        authAddress1 = userData?.authAddress1 ?? false
//        address2 = userData?.address2 ?? ""
//        authAddress2 = userData?.authAddress2 ?? false
//        
//        configAddressButtonLayout()
//        configAddressButton()
//
//    }
//    
//    func changeAddressButton(isOn: Bool, view: UIView, label: UILabel, button: UIButton) {
//        if isOn {
//            view.backgroundColor = .orange
//            view.layer.borderWidth = 0
//            
//            label.textColor = .white
//            
//            button.tintColor = .white
//            
//        } else {
//            view.backgroundColor = .white
//            view.layer.borderWidth = 1
//            view.layer.borderColor = UIColor.lightGray.cgColor
//            
//            label.textColor = .black
//            
//            button.tintColor = .lightGray
//        }
//    }
//    
//    
//    
//    func configAddressButton() {
//        
//        // 이미 설정한 동네인지 체크 필요
//        if address1 == address2 {
//            address2 = ""
//            // 토스트 메시지 추가 필요
//        } else {
//            // 두번째 동네가 비어있다면
//            if address2 == "" {
//                firstAddressLabel.text = address1.components(separatedBy: " ").last ?? ""
//                changeAddressButton(isOn: true, view: firstAddressView, label: firstAddressLabel, button: deleteFirstAddressButton)
//                secondAddressView.isHidden = true
//                emptySecondAddressButton.isHidden = false
//            } else { // 두번째 동네가 비어있지 않다면
//                firstAddressLabel.text = address1.components(separatedBy: " ").last ?? ""
//                secondAddressLabel.text = address2.components(separatedBy: " ").last ?? ""
//                secondAddressView.isHidden = false
//                emptySecondAddressButton.isHidden = true
//                
//                if selectedAddress == address1 {
//                    changeAddressButton(isOn: true, view: firstAddressView, label: firstAddressLabel, button: deleteFirstAddressButton)
//                    changeAddressButton(isOn: false, view: secondAddressView, label: secondAddressLabel, button: deleteSecondAddressButton)
//                } else {
//                    changeAddressButton(isOn: false, view: firstAddressView, label: firstAddressLabel, button: deleteFirstAddressButton)
//                    changeAddressButton(isOn: true, view: secondAddressView, label: secondAddressLabel, button: deleteSecondAddressButton)
//                }
//            }
//        }
//    }
//    
//    func configAddressButtonLayout() {
//        firstAddressView.layer.cornerRadius = 5
//        secondAddressView.layer.cornerRadius = 5
//
//        emptySecondAddressButton.layer.borderColor = UIColor.lightGray.cgColor
//        emptySecondAddressButton.layer.borderWidth = 1
//        emptySecondAddressButton.layer.cornerRadius = 5
//        emptySecondAddressButton.tintColor = .lightGray
//    }
//    
//    @IBAction func tapFirstAddressButton(_ sender: Any) {
//        selectedAddress = address1
//        configAddressButton()
//    }
//    
//    @IBAction func tapSecondAddressButton(_ sender: Any) {
//        selectedAddress = address2
//        configAddressButton()
//    }
//    
//
//    @IBAction func tapAddSecondAddressButton(_ sender: Any) {
//        let storyboard = UIStoryboard(name: "Login", bundle: nil)
//        guard let vc = storyboard.instantiateViewController(withIdentifier: "addressVC") as? AddressListViewController else { return }
//        vc.isSetting = true
//        vc.isFirstButton = false
//        vc.delegate = self
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
//
//    func deleteAddress(buttonTag: Int) {
//        if address2 == "" {
//            let alert = UIAlertController(title: "", message: "동네가 1개만 선택된 상태에서는 삭제를 할 수 없어요. 현재 설정된 동네를 변경하시겠어요?", preferredStyle: .alert)
//            let ok = UIAlertAction(title: "변경", style: .default) { _ in
//                let storyboard = UIStoryboard(name: "Login", bundle: nil)
//                guard let vc = storyboard.instantiateViewController(withIdentifier: "addressVC") as? AddressListViewController else { return }
//                vc.isSetting = true
//                vc.isFirstButton = true
//                vc.delegate = self
//                
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
//            
//            let cancel = UIAlertAction(title: "취소", style: .cancel)
//            
//            alert.addAction(cancel)
//            alert.addAction(ok)
//            self.present(alert, animated: true)
//        } else {
//            let alert = UIAlertController(title: "", message: "선택한 지역을 삭제하시겠습니까?", preferredStyle: .alert)
//            
//            let ok = UIAlertAction(title: "확인", style: .default) { _ in
//                if buttonTag == 100 {
//                    // 동네가 2개인 상태에서 1번 지우면
//                    // 2번째 동네를 1번으로
//                    self.selectedAddress = self.address2
//                    self.address1 = self.address2
//                    self.authAddress1 = self.authAddress2
//                    self.address2 = ""
//                    self.authAddress2 = false
//                } else {
//                    // 동네가 2개인 상태에서 2번 지우면
//                    // 그냥 2번 지우기
//                    self.selectedAddress = self.address1
//                    self.address2 = ""
//                    self.authAddress2 = false
//                }
//                self.configAddressButton()
//            }
//            
//            let cancel = UIAlertAction(title: "취소", style: .cancel)
//            alert.addAction(cancel)
//            alert.addAction(ok)
//            self.present(alert, animated: true)
//        }
//    }
//    
//    @IBAction func deleteFirstAddressButton(_ sender: Any) {
//        guard let button = sender as? UIButton else { return }
//        deleteAddress(buttonTag: button.tag)
//    }
//
//    @IBAction func deleteSecondAddressButton(_ sender: Any) {
//        guard let button = sender as? UIButton else { return }
//        deleteAddress(buttonTag: button.tag)
//    }
//
//    @IBAction func tapBackButton(_ sender: Any) {
//    
//        // 파이어베이스에 지역 정보 업데이트할 데이터
//        let updateData = ["selectedAddress": selectedAddress,
//                          "address1": address1,
//                          "authAddress1": authAddress1,
//                          "address2": address2,
//                          "authAddress2": authAddress2] as [String: Any]
//        
//        guard var userData = userData else { return }
//        
//        userData.selectedAddress = selectedAddress
//        userData.address1 = address1
//        userData.authAddress1 = authAddress1
//        userData.address2 = address2
//        userData.authAddress2 = authAddress2
//        
//        // 데이터 업데이트 후 저장
//        UserModel.saveUserData(userData: userData)
//        
//        guard let rootVC = delegate else { return }
//        
//        FirebaseManager.shared.updateAddressData(userPhoneNumber: userData.phoneNumber ?? "", data: updateData) {
//            rootVC.updateAddressButton()
//            rootVC.fetchProducts()
//            self.dismiss(animated: true)
//        }
//    }
//}
//
//extension SettingAddressViewController: AddressListViewControllerDelegate {
//    func sendSelectedAddress(address: String, isFirstButton: Bool) {
// 
//        if isFirstButton {
//            self.selectedAddress = address
//            self.address1 = address
//        } else {
//            self.selectedAddress = address
//            self.address2 = address
//        }
//        
//        configAddressButton()
//    }
//}
//
