//
//  NicknameConfigureViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/10/10.
//

import UIKit
import Firebase
import FirebaseFirestore
import CoreLocation
import BSImagePicker

// MARK: [Class or Struct] ----------
class NicknameConfigureViewController: UIViewController {
    
    // MARK: [@IBOutlet] ----------
    @IBOutlet var nicknameTextField: UITextField!
    @IBOutlet var nicknameCheckLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var profileImageView: UIImageView!
    
    // MARK: [Let Or Var] ----------
    var userData: UserModel?
    
    let imagePicker = ImagePickerController()
    let db = Firestore.firestore()
    

    // MARK: [Override] ----------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.image = UIImage(named: "user")
        doneButton.isEnabled = false
        nicknameTextField.addTarget(self, action: #selector(nicknameFieldDidChange), for: .editingChanged)
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        appearance.setBackIndicatorImage(UIImage(systemName: "chevron.backward"), transitionMaskImage: UIImage(systemName: "chevron.backward"))
        self.navigationItem.scrollEdgeAppearance = appearance
        self.navigationItem.standardAppearance = appearance
        
        configLayout()
    }

    
    // MARK: [@IBAction] ----------
    @IBAction func tapDoneButton(_ sender: Any) {
        createUser()
    }
    
    @IBAction func addProfileImageButton(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "닫기", style: .cancel)
        let deleteProfileImage = UIAlertAction(title: "프로필 사진 삭제", style: .destructive) { _ in
            self.profileImageView.image = UIImage(named: "user")
        }
        let add = UIAlertAction(title: "앨범에서 선택", style: .default) { _ in
            
            self.bsImagePicker(max: 1) { assets in
                let image = self.convertAssetToImages(assetArr: assets)[0]
                self.profileImageView.image = image.resizeThumbnailTo()
                self.imagePicker.deselect(asset: assets[0])
            }
        }
        
        // 선택한 프로필 사진이 있거나 없으면 alert분기
        if profileImageView.image == UIImage(named: "user") {
            alert.addAction(cancel)
            alert.addAction(add)
        } else {
            alert.addAction(cancel)
            alert.addAction(add)
            alert.addAction(deleteProfileImage)
        }
        present(alert, animated: true)
    }
    
    
    // MARK: [Function] ----------
    func createUser() {
        
        print("2",userData)
        
        guard let target = userData else { return }
        
        
        
        var profileImage = [UIImage]()
        profileImage.append(profileImageView.image ?? UIImage())
        
        FirebaseManager.shared.uploadImages(documentId: "", phoneNumber: userData?.phoneNumber ?? "", images: profileImage, uploadType: .profileImage) { result in
            switch result {
            case .success(let imageUrls):
                let userData = [
                    "selectedAddress": target.selectedAddress,
                    "address1": target.address1,
                    "authAddress1": target.authAddress1,
                    "address2": target.address2 ?? "",
                    "authAddress2": target.authAddress2,
                    "nickname": self.nicknameTextField.text ?? "",
                    "phoneNumber": target.phoneNumber ?? "",
                    "profileImageUrl": imageUrls[0],
                ] as [String : Any]
                
                self.db.collection("유저정보").document(self.userData?.phoneNumber ?? "").setData(userData) { error in
                    if let error = error {
                        print("파이어베이스 유저정보 저장 실패 - \(error)")
                    } else {
                        // 유저 정보 유저디폴트에 저장하기
                        print("UserDefault - 유저정보 저장 성공")
                        UserModel.saveUserData(userData: UserModel(data: userData))
                        
                        let tabbarName = UIStoryboard(name: "Tabbar", bundle: nil)
                        let tabbarVC = tabbarName.instantiateViewController(withIdentifier: "tabbar")
                        UIApplication.shared.windows.first?.rootViewController = tabbarVC
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func configLayout() {
        profileImageView.contentMode = .scaleToFill
        profileImageView.layer.cornerRadius = profileImageView.frame.width * 0.5
        
        nicknameTextField.layer.borderColor = UIColor.red.cgColor
        nicknameTextField.layer.borderWidth = 1.0
        nicknameTextField.layer.cornerRadius = 5
        
        doneButton.layer.cornerRadius = 5
    }
    
    func changeBorderColorAndButtonIsEnable(textColor: UIColor, borderColor: CGColor, isEnable: Bool) {
        nicknameTextField.layer.borderColor = borderColor
        nicknameTextField.layer.borderWidth = 1.0
        nicknameCheckLabel.tintColor = textColor
        doneButton.isEnabled = isEnable
    }

    // MARK: [@objc Function] ----------
    @objc func nicknameFieldDidChange() {
        guard let nickname = nicknameTextField.text else { return }
        
        if nickname.isEmpty {
            nicknameCheckLabel.text = " "
            changeBorderColorAndButtonIsEnable(textColor: .red, borderColor: UIColor.red.cgColor, isEnable: false)
        } else if nickname.count < 2 {
            nicknameCheckLabel.text = "두글자 이상 입력해주세요."
            changeBorderColorAndButtonIsEnable(textColor: .red, borderColor: UIColor.red.cgColor, isEnable: false)
        } else if nickname.count > 12 {
            nicknameCheckLabel.text = "닉네임은 12자리 이하로 해주세요."
            changeBorderColorAndButtonIsEnable(textColor: .red, borderColor: UIColor.red.cgColor, isEnable: false)
        } else if nickname.isValidNickname() {
            nicknameCheckLabel.text = "닉네임을 입력해주세요."
            changeBorderColorAndButtonIsEnable(textColor: .gray, borderColor: UIColor.black.cgColor, isEnable: true)
        } else {
            nicknameCheckLabel.text = "닉네임은 띄어쓰기 없이 한글, 영문, 숫자만 가능해요."
            changeBorderColorAndButtonIsEnable(textColor: .red, borderColor: UIColor.red.cgColor, isEnable: false)
        }
    }
}

