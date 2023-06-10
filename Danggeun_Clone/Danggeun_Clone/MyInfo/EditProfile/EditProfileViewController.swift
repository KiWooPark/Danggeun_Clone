//
//  EditProfileViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/02/10.
//

import UIKit
import BSImagePicker

// MARK: [Protocol] ----------
protocol EditProfileViewControllerDelegate: AnyObject {
    func updateProfileData(nickname: String?, profileImage: UIImage?)
}

// MARK: [Class or Struct] ----------
class EditProfileViewController: UIViewController {

    // MARK: [@IBOutlet] ----------
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var selectPhotoButton: UIButton!
    @IBOutlet var nicknameTextField: UITextField!
    @IBOutlet var nicknameCheckLabel: UILabel!
    
    @IBOutlet var checkLabelUpCenterY: NSLayoutConstraint!
    @IBOutlet var checkLabelDownCenterY: NSLayoutConstraint!
    
    @IBOutlet var doneButton: UIBarButtonItem!
    
    // MARK: [Let Or Var] ----------
    var profileImage: UIImage?
    var userData: UserModel?
    
    var oldProfileImage = UIImage()
    var oldNickname = ""
    
    weak var editProfileViewDelegate1: EditProfileViewControllerDelegate?
    weak var editProfileViewDelegate2: EditProfileViewControllerDelegate?
    
    let imagePicker = ImagePickerController()
    
    var nicknameTextFieldTimer: Timer?
    
    // MARK: [Override] ----------
    override func viewDidLoad() {
        super.viewDidLoad()

        configData()
        configLayout()
        
        oldNickname = userData?.nickname ?? ""
        oldProfileImage = profileImage ?? UIImage(named: "user")!
        profileImageView.layer.cornerRadius = 125 / 2
    }
    
    // MARK: [@IBAction] ----------
    @IBAction func tapSelectePhotoButton(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "닫기", style: .cancel)
        let deleteProfileImage = UIAlertAction(title: "프로필 사진 삭제", style: .destructive) { _ in
            self.profileImage = nil
            self.profileImageView.image = UIImage(named: "user")
        }
        let add = UIAlertAction(title: "앨범에서 선택", style: .default) { _ in
            
            self.bsImagePicker(max: 1) { assets in
                let image = self.convertAssetToImages(assetArr: assets)[0]
                self.profileImage = image
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
    
    @IBAction func tapDoneButton(_ sender: Any) {

        guard let nicknameText = nicknameTextField.text else { return }
        
        if nicknameText == oldNickname && profileImageView.image == oldProfileImage {
            self.dismiss(animated: true)
        }
        
        var resultNickname: String? = nil
        var resultProfileImage: UIImage? = nil
        var loginUserData = UserModel.getUserData()
        
    
        // 닉네임 이미지 다 바꾼경우
        if profileImageView.image != oldProfileImage && nicknameText != oldNickname {
            
            resultNickname = nicknameText
            resultProfileImage = profileImageView.image
            
            // 이미지만 바꾼경우
        } else if profileImageView.image != oldProfileImage && nicknameText == oldNickname {
            
            resultProfileImage = profileImageView.image
        
            
            // 닉네임만 바꾼경우
        } else if profileImageView.image == oldProfileImage && nicknameText != oldNickname {
            
            resultNickname = nicknameText
        }
     
        FirebaseManager.shared.updateProfileData(phoneNumber: userData?.phoneNumber ?? "", nickname: resultNickname, profileImage: resultProfileImage) { userData in
            
            UserModel.saveUserData(userData: userData)
            self.editProfileViewDelegate1?.updateProfileData(nickname: resultNickname, profileImage: resultProfileImage)
            self.editProfileViewDelegate2?.updateProfileData(nickname: resultNickname, profileImage: resultProfileImage)
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func tapCloseButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    // MARK: [Function] ----------
    func configData() {
        profileImageView.image = profileImage
        nicknameTextField.text = userData?.nickname ?? ""
    }
    
    func configLayout() {
        nicknameTextField.addTarget(self, action: #selector(nicknameFieldDidChange), for: .editingChanged)
    }

    // MARK: [@objc Function] ----------
    @objc func nicknameFieldDidChange() {

        nicknameTextFieldTimer?.invalidate()
        
        nicknameTextFieldTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkNicknameCheckLabel), userInfo: nil, repeats: false)
    }
    
    @objc func checkNicknameCheckLabel() {
        
        UIView.animate(withDuration: 0.3) {
            self.checkLabelUpCenterY.priority = .defaultLow
            self.checkLabelDownCenterY.priority = .defaultHigh
            self.view.layoutIfNeeded()
        }
        
        guard let nickname = nicknameTextField.text else { return }
        
        if nickname.isEmpty {
            nicknameCheckLabel.text = "닉네임을 입력해주세요!"
            doneButton.isEnabled = false
        } else if nickname.count < 2 {
            nicknameCheckLabel.text = "닉네임은 2자 이상 입력해주세요."
            doneButton.isEnabled = false
        } else if nickname.count > 12 {
            nicknameCheckLabel.text = "닉네임은 12자리 이하로 입력해주세요."
            doneButton.isEnabled = false
        } else if !nickname.isValidNickname()  {
            nicknameCheckLabel.text = "닉네임은 띄어쓰기 없이 한글, 영문, 숫자만 가능해요."
            doneButton.isEnabled = false
        } else {
            doneButton.isEnabled = true
            UIView.animate(withDuration: 0.3) {
                self.checkLabelUpCenterY.priority = .defaultHigh
                self.checkLabelDownCenterY.priority = .defaultLow
                self.view.layoutIfNeeded()
            }
        }
    }
}
