//
//  EditProfileViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/07/21.
//

import UIKit
import Photos

/*
 프로필 이미지 or 닉네임 변경되면 서버에 업데이트
 유저 디폴트에도 저장하기
 함수로 빼서 작업하기
 닉네임 길이 판단하기
 */

class EditProfileViewController1: UIViewController {

    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var warningMessageLabel: UILabel!
    @IBOutlet var nicknameTextField: UITextField!
    @IBOutlet var doneButton: UIBarButtonItem!
    
    @IBOutlet var warningMessageLabelCenterVertical: NSLayoutConstraint!
    
    var userData: UserModel?
    var profileImage: UIImage?
    var nickname: String?

    
    var isNickname = false
    var isProfileImage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileImageView.layer.cornerRadius = profileImageView.frame.height * 0.5
        
        nicknameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        doneButton.isEnabled = false
        
        profileImageView.image = profileImage
        nicknameTextField.text = nickname
        
    }
    
    @IBAction func tapProfileImageButton(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let selectPhoto = UIAlertAction(title: "앨범에서 선택", style: .default) { _ in
            print("앨범에서 선택 클릭")
           
            self.bsImagePicker(max: 1) { assets in
                self.profileImage = self.convertAssetToImages(assetArr: assets)[0]
                self.profileImageView.image = self.profileImage?.resizeThumbnailTo()
                
                self.isProfileImage = true
                self.doneButton.isEnabled = true
            }
        }
        let cancel = UIAlertAction(title: "닫기", style: .cancel)
        alert.addAction(selectPhoto)
        alert.addAction(cancel)
        self.present(alert, animated: true)
    }

    
    @IBAction func tapDoneButton(_ sender: Any) {
//        // 유저정보 컬렉션
//        profileImage = isProfileImage ? profileImage : nil
//
//        FirebaseManager.shared.uploadImage(image: profileImage, position: nil, uploadType: .profileImage) { url, _ in
//
//            let url = url?.absoluteString ?? nil
//            guard let nickname = self.nickname else { return }
//
//            FirebaseManager.shared.updateProfile(phoneNumber: self.userData?.phone ?? "", profileImageUrl: url, nickname: nickname)
//            FirebaseManager.shared.updateUserProfileToChatRoom(phoneNumber: self.userData?.phone ?? "", profileImageUrl: url, nickname: nickname)
//
//            if url != nil {
//                self.userData?.profileImageUrl = url
//                self.userData?.nickName = nickname
//            } else {
//                self.userData?.nickName = nickname
//            }
//
//            if let userData = self.userData {
//                UserModel.saveUserData(userData: userData)
//            }
//        }
    }
    
    @IBAction func tapBackButton(_ sender: Any) {
        self.navigationController?.dismiss(animated: true)
    }
    
    @objc func textDidChange() {
        
        guard let text = nicknameTextField.text else { return }
        nickname = text
        
        if text.isEmpty {
            warningMessageLabel.text = "닉네임을 입력해주세요."
            doneButton.isEnabled = false
            isNickname = false
        } else if text.count < 2 {
            warningMessageLabel.text = "닉네임은 2글자 이상 입력해주세요."
            doneButton.isEnabled = false
            isNickname = false
        } else if text.count > 12 {
            warningMessageLabel.text = "닉네임은 12자 이하로 입력해주세요."
            doneButton.isEnabled = false
            isNickname = false
        } else if !text.isValidNickname() {
            warningMessageLabel.text = "닉네임은 띄어쓰기 없이 한글, 영문, 숫자만 가능해요."
            doneButton.isEnabled = false
            isNickname = false
        } else {
            doneButton.isEnabled = true
            isNickname = true
        }
        
        if isNickname {
            warningMessageLabelCenterVertical.constant = 0
        } else {
            warningMessageLabelCenterVertical.constant = 30
        }
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0.5) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            if self.isNickname {
                self.warningMessageLabel.text = " "
            }
        }
    }
}


