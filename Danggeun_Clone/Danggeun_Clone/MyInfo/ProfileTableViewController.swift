//
//  ProfileTableViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/07/21.
//

import UIKit
import FirebaseFirestore
import Kingfisher

class ProfileTableViewController: UITableViewController {
    
    @IBOutlet var profileTableView: UITableView!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var nicknameLabel: UILabel!
    @IBOutlet var editProfileButton: UIButton!
    @IBOutlet var temperatureProgressBar: UIProgressView!
    
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var productsCountLabel: UILabel!
    
    @IBOutlet var profileImageViewHeight: NSLayoutConstraint!
    
    let db = Firestore.firestore()
    
    var userData: UserModel?
    
    var produsts = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //profileTableView.rowHeight = UITableView.automaticDimension
        //profileTableView.estimatedRowHeight = 500
        editProfileButton.layer.borderColor = UIColor.gray.cgColor
        editProfileButton.layer.borderWidth = 1
        
        if userData?.phoneNumber != UserModel.getUserData()?.phoneNumber {
            editProfileButton.isHidden = true
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        db.collection("유저정보").whereField("phoneNumber", isEqualTo: userData?.phoneNumber ?? "").getDocuments { snapShot, error in
            if let error = error {
                print("유저정보 가져오기 실패")
            }

            guard let documents = snapShot?.documents.first else { return }

            self.userData = UserModel(data: documents.data())

            let temperature = Float(self.userData?.temperature ?? 0.0) * 0.01
            self.temperatureLabel.text = "\(self.userData?.temperature ?? 0.0)℃"
            self.temperatureProgressBar.setProgress(ceil(temperature * 10000) / 10000, animated: true)

            FirebaseManager.shared.downloadImagesTest(url: self.userData?.profileImageUrl ?? "") { image in
                DispatchQueue.main.async {
                    self.profileImageView.image = image == nil ? UIImage(named: "user") : image?.resizeThumbnailTo()
                }
            }
            self.nicknameLabel.text = self.userData?.nickname ?? ""
        }
        
        // 내가 올린 상품 가져오기
        db.collection("유저정보").document(userData?.phoneNumber ?? "").getDocument { snapShot, error in
            if let error = error {
                print("내가 올린 상품 가져오기 실패")
            }
            
            self.produsts = snapShot?.data()?["products"] as? [String] ?? []
            self.productsCountLabel.text = "판매상품 \(self.produsts.count)개"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nextVC = segue.destination as? UINavigationController else { return }
        guard let targetVC = nextVC.topViewController as? EditProfileViewController1 else { return }
        targetVC.nickname = nicknameLabel.text
        targetVC.profileImage = profileImageView.image
        targetVC.userData = userData
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 && indexPath.row == 0 {
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "myproductsListVC") as? MyProductsListViewController else { return }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func viewWillLayoutSubviews() {
        profileImageViewHeight.constant = self.view.frame.height * 8 / 100
        profileImageView.layer.cornerRadius = profileImageView.frame.height * 0.5
    }
    
    @IBAction func testButton(_ sender: Any) {
        
    }
    
    
//    // 셀높이 동적으로 사용
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
//
//    // 헤더뷰 높이
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return CGFloat.leastNormalMagnitude
//    }
//
//    // 푸터뷰 높이
//    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 5
//    }
}
