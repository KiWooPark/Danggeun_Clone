//
//  AuthPhoneNumberViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/10/08.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import CoreLocation
import FirebaseMessaging

// MARK: [Class or Struct] ----------
class AuthPhoneNumberViewController: UIViewController {
    
    // MARK: [@IBOutlet] ----------
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var title2Label: UILabel!
    @IBOutlet var signContentLabel: UILabel!
    
    @IBOutlet var getSMSButton: UIButton!
    @IBOutlet var signInButton: UIButton!
    
   
    
    @IBOutlet var titleStackView: UIStackView!
    @IBOutlet var authStackView: UIStackView!
    @IBOutlet var emailStackView: UIStackView!
    
    @IBOutlet var phoneNumberTextField: UITextField!
    @IBOutlet var signInNumberTextField: UITextField!
    
    // MARK: [let or var] ----------
    let db = Firestore.firestore()
    private var verifyID = ""
    
    // 뷰컨트롤러 타입 체크
    var vcType = VCType.authVC
    
    // 가입인지 로그인인지
    var isNewJoin: Bool?
    var isBeforeVC: Bool?
    
    var userData: UserModel?
    
    var isSendNumber = false
    
    // MARK: [Override] ----------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLayout()
    }
    
    // MARK: [@IBAction] ----------
    // 인증번호 요청 버튼 터치
    @IBAction func tapRequestSMSButton(_ sender: Any) {
        guard let phoneNumber = phoneNumberTextField.text else { return }
        requestSMS(phoneNumber: phoneNumber.replacingOccurrences(of: " ", with: ""))
        
        titleStackView.alpha = 0
        authStackView.isHidden = false
        emailStackView.isHidden = true
        
        UIView.animate(withDuration: 0.5) {
            self.titleStackView.isHidden = true
            self.signInNumberTextField.becomeFirstResponder()
        }
    }
    
    // 인증 과정 거치고 넘어가기
    @IBAction func tapCheckSignInNumberButton(_ sender: Any) {
        print("인증번호 확인")
        guard let signInNumber = signInNumberTextField.text else { return }
        
        // verifyID - 인증데이터
        // signInNumber - 인증번호
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verifyID, verificationCode: signInNumber)
        
        Auth.auth().signIn(with: credential) { success, error in
            if let error = error {
                print("인증번호 에러 \(error.localizedDescription)")
                
                self.signInNumberTextField.layer.borderColor = UIColor.red.cgColor
                self.signContentLabel.text = "인증문자를 다시 입력해주세요."
                self.signContentLabel.textColor = .red
                
                return
            }
            // 데이터베이스 체크
            self.checkDBUserData()
        }
    }
    
    @IBAction func tapBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: [Function] ----------
    func configureLayout() {
        titleLabel.text = isNewJoin ?? false ? "안녕하세요!\n휴대폰 번호로 가입 해주세요." : "안녕하세요!\n휴대폰 번호로 로그인 해주세요."
    
        phoneNumberTextField.layer.borderWidth = 1
        phoneNumberTextField.layer.cornerRadius = 5
        phoneNumberTextField.layer.borderColor = UIColor.black.cgColor
        
        getSMSButton.layer.borderColor = UIColor.systemGray4.cgColor
        getSMSButton.layer.borderWidth = 1
        getSMSButton.layer.cornerRadius = 5
        getSMSButton.isEnabled = false
        
        signInNumberTextField.layer.borderWidth = 1
        signInNumberTextField.layer.cornerRadius = 5
        signInNumberTextField.layer.borderColor = UIColor.black.cgColor
        
        signInButton.layer.cornerRadius = 5
    }
    
    // 인증번호 요청하기
    func requestSMS(phoneNumber: String) {
        PhoneAuthProvider.provider().verifyPhoneNumber("+82\(phoneNumber)", uiDelegate: nil) { verificationID, error in
            if let error = error {
                print("error = \(error.localizedDescription)")
                return
            }
                    
            self.verifyID = verificationID ?? ""
            print(#function,"요청 완료")
        }
    }
    
    func checkDBUserData() {
        guard let phoneNumber = phoneNumberTextField.text?.replacingOccurrences(of: " ", with: "") else { return }

        FirebaseManager.shared.getUserData(userPhoneNumber: phoneNumber) { resultUserData in
            if resultUserData == nil {
                if self.vcType == .loginVC {
                    guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "addressVC") as? AddressListViewController else { return }

                    vc.vcType = VCType.authVC
                    vc.phoneNumber = phoneNumber

                    self.navigationController?.pushViewController(vc, animated: true)
                } else if self.vcType == .addressVC {
                    guard let vc =  self.storyboard?.instantiateViewController(withIdentifier: "nickname") as? NicknameConfigureViewController else { return }

                    self.userData?.phoneNumber = phoneNumber
                    vc.userData = self.userData

                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                UserModel.saveUserData(userData: resultUserData)

                let tabbarName = UIStoryboard(name: "Tabbar", bundle: nil)
                let tabbarVC = tabbarName.instantiateViewController(withIdentifier: "tabbar")
                UIApplication.shared.windows.first?.rootViewController = tabbarVC
            }
        }
    }
}

// MARK: [TextField - Delegate] ----------
extension AuthPhoneNumberViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        
        switch textField.tag {
        case 0:
            if range.length == 0 {
                if range.location == 3 {
                    textField.text = text + " "
                } else if range.location == 8 {
                    textField.text = text + " "
                } else if range.location == 13 {
                    return false
                }
                
                if range.location >= 8 {
                    getSMSButton.isEnabled = true
                }
            } else if range.length > 0 {
                if range.location <= 9 {
                    getSMSButton.isEnabled = false
                }
            }
            return true
        case 1:
            if range.length == 0 {
                if range.location == 1 {
                    signInButton.isEnabled = true
                    signInButton.backgroundColor = UIColor(displayP3Red: 237/255, green: 125/255, blue: 52/255, alpha: 1)
                    signInButton.tintColor = .white
                } else if range.location == 6 {
                    return false
                }
            } else if range.length > 0 {
                if range.location == 0 {
                    self.signInButton.isEnabled = false
                    self.signInButton.backgroundColor = .systemGray4
                    self.signInButton.tintColor = .systemGray
                }
            }
            return true
        default:
            return false
        }
    }
}



