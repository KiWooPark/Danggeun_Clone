//
//  AddressSettingViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/02/08.
//

import UIKit

// MARK: [Protocol] ----------
protocol AddressSettingViewControllerDelegate: AnyObject {
    func fetchProducts()
}

// MARK: [Class or Struct] ----------
class AddressSettingViewController: UIViewController {
    
    // MARK: [@IBOutlet] ----------
    @IBOutlet var firstBaseView: UIView!
    @IBOutlet var secondBaseView: UIView!
    
    @IBOutlet var firstAddressLabel: UILabel!
    @IBOutlet var secondAddressLabel: UILabel!
    
    @IBOutlet var firstDeleteButton: UIButton!
    @IBOutlet var secondDeleteButton: UIButton!
    
    @IBOutlet var AddAddressButton: UIButton!

    // MARK: [Let Or Var] ----------
    var loginUserData = UserModel.getUserData()
    weak var delegate: AddressSettingViewControllerDelegate?
    var accessController = AccessControllerType.none

    // MARK: [Override] ----------
    override func viewDidLoad() {
        super.viewDidLoad()
    
        configAddressButtonLayout()
        configAddressButton()
        updateAddressButtonLayout()
    }
    
    // MARK: [@IBAction] ----------
    @IBAction func tapFirstAddressButton(_ sender: Any) {
        let address1 = loginUserData?.address1 ?? ""
        loginUserData?.selectedAddress = address1
        updateAddressButtonLayout()
        
    }
    
    @IBAction func tapFirstDeleteButton(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        deleteAddress(tag: button.tag)
        
    }
    
    @IBAction func tapSecondAddressButton(_ sender: Any) {
        let address2 = loginUserData?.address2 ?? ""
        loginUserData?.selectedAddress = address2
        updateAddressButtonLayout()
    }
    
    @IBAction func tapSecondDeleteButton(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        deleteAddress(tag: button.tag)
    }
    
    @IBAction func tapAddAddressButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "addressVC") as? AddressListViewController else { return }
        vc.isSetting = true
        vc.isFirstButton = false
        vc.delegate = self
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func tapBackButton(_ sender: Any) {
        
        if let loginUserData = loginUserData {
            UserModel.saveUserData(userData: loginUserData)

            FirebaseManager.shared.updateAddressData(userPhoneNumber: loginUserData.phoneNumber ?? "", data: loginUserData) {
                
                if self.accessController == .homeVC {
                    self.delegate?.fetchProducts()
                } else {
                    NotificationCenter.default.post(name: .reloadMainViewProducts, object: nil)
                }
                
                self.dismiss(animated: true)
            }
        }
    }
    
    // MARK: [Function] ----------
    func configAddressButtonLayout() {
        firstBaseView.layer.cornerRadius = 5
        secondBaseView.layer.cornerRadius = 5
        
        AddAddressButton.layer.borderColor = UIColor.lightGray.cgColor
        AddAddressButton.layer.borderWidth = 1
        AddAddressButton.layer.cornerRadius = 5
    }
    
    func configAddressButton() {
        if loginUserData?.address2 == "" {
            firstAddressLabel.text = loginUserData?.address1.components(separatedBy: " ").last ?? ""
            secondBaseView.isHidden = true
            AddAddressButton.isHidden = false
            
        } else {
            firstAddressLabel.text = loginUserData?.address1.components(separatedBy: " ").last ?? ""
            secondAddressLabel.text = loginUserData?.address2?.components(separatedBy: " ").last ?? ""
            secondBaseView.isHidden = false
            AddAddressButton.isHidden = true
        }
        
//        if loginUserData?.address1 == loginUserData?.address2 ?? "" {
//            // *추가*
//            // 이미 추가되어있는 동네면 토스트 메시지
//
//        } else {
//            if loginUserData?.address2 == "" {
//                firstAddressLabel.text = loginUserData?.address1.components(separatedBy: " ").last ?? ""
//                secondBaseView.isHidden = true
//                AddAddressButton.isHidden = false
//
//            } else {
//                firstAddressLabel.text = loginUserData?.address1.components(separatedBy: " ").last ?? ""
//                secondAddressLabel.text = loginUserData?.address2?.components(separatedBy: " ").last ?? ""
//                secondBaseView.isHidden = false
//                AddAddressButton.isHidden = true
//            }
//        }
    }
    
    func updateAddressButtonLayout() {
        if loginUserData?.selectedAddress == loginUserData?.address1 {
            firstBaseView.backgroundColor = .orange
            firstBaseView.layer.borderWidth = 0
            firstAddressLabel.textColor = .white
            firstDeleteButton.tintColor = .white
        } else {
            firstBaseView.backgroundColor = .white
            firstBaseView.layer.borderWidth = 1
            firstBaseView.layer.borderColor = UIColor.lightGray.cgColor
            firstAddressLabel.textColor = .black
            firstDeleteButton.tintColor = .lightGray
        }
        
        if loginUserData?.selectedAddress == loginUserData?.address2 ?? "" {
            secondBaseView.backgroundColor = .orange
            secondBaseView.layer.borderWidth = 0
            secondAddressLabel.textColor = .white
            secondDeleteButton.tintColor = .white
        } else {
            secondBaseView.backgroundColor = .white
            secondBaseView.layer.borderWidth = 1
            secondBaseView.layer.borderColor = UIColor.lightGray.cgColor
            secondAddressLabel.textColor = .black
            secondDeleteButton.tintColor = .lightGray
        }
        
        if loginUserData?.address2 == "" {
            secondBaseView.isHidden = true
            AddAddressButton.isHidden = false
        }
    }
    
    func deleteAddress(tag: Int) {
        if loginUserData?.address2 == "" {
            let alert = UIAlertController(title: "", message: "동네가 1개만 선택된 상태에서는 삭제를 할 수 없어요. 현재 설정된 동네를 변경하시겠어요?", preferredStyle: .alert)
            let ok = UIAlertAction(title: "변경", style: .default) { _ in
                let storyboard = UIStoryboard(name: "Login", bundle: nil)
                guard let vc = storyboard.instantiateViewController(withIdentifier: "addressVC") as? AddressListViewController else { return }
                vc.isSetting = true
                vc.isFirstButton = true
                vc.delegate = self
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            let cancel = UIAlertAction(title: "취소", style: .cancel)
            
            alert.addAction(cancel)
            alert.addAction(ok)
            self.present(alert, animated: true)
        } else if loginUserData?.address1 != "" && loginUserData?.address2 != "" {
            let alert = UIAlertController(title: "", message: "선택한 지역을 삭제하시겠습니까?", preferredStyle: .alert)
            let ok = UIAlertAction(title: "확인", style: .default) { _ in
                switch tag {
                case 100:
                    let address2 = self.loginUserData?.address2 ?? ""
                    self.loginUserData?.selectedAddress = address2
                    self.loginUserData?.address1 = address2
                    self.loginUserData?.address2 = ""
                case 101:
                    let address1 = self.loginUserData?.address1 ?? ""
                    self.loginUserData?.selectedAddress = address1
                    self.loginUserData?.address2 = ""
                default:
                    print("deleteAddress default")
                }
                
                self.configAddressButton()
                self.updateAddressButtonLayout()
                
            }
            let cancel = UIAlertAction(title: "취소", style: .cancel)
            alert.addAction(cancel)
            alert.addAction(ok)
            self.present(alert, animated: true)
        }
    }
}

// MARK: [Extention Delegate] ----------
extension AddressSettingViewController: AddressListViewControllerDelegate {
    func sendSelectedAddress(address: String, isFirstButton: Bool) {
        
        if isFirstButton {
            loginUserData?.selectedAddress = address
            loginUserData?.address1 = address
            loginUserData?.authAddress1 = false
        } else {
            loginUserData?.selectedAddress = address
            loginUserData?.address2 = address
            loginUserData?.authAddress2 = false
        }
        self.configAddressButton()
        self.updateAddressButtonLayout()
    }
}
