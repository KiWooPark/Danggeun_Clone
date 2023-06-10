//
//  MyInfoTableViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/07/21.
//

import UIKit
import Kingfisher

class MyInfoTableViewController: UITableViewController {

    @IBOutlet var myInfoTableView: UITableView!
    @IBOutlet var profileImageView: UIImageView!
    
    @IBOutlet var soldDetailView: UIView!
    @IBOutlet var boughtDetailView: UIView!
    @IBOutlet var interestListView: UIView!
    
    @IBOutlet var nicknameLabel: UILabel!
    @IBOutlet var regionLabel: UILabel!
    
    @IBOutlet var profileImageViewHeight: NSLayoutConstraint!
    @IBOutlet var soldViewHeight: NSLayoutConstraint!
    
    var loginUserData: UserModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 네비게이션바 투명해지지 않게 하기
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = .white
        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
        // 셀높이 동적으로 사용
        //myInfoTableView.rowHeight = UITableView.automaticDimension
        //myInfoTableView.estimatedRowHeight = 200
        
        // 탭바컨트롤러 백그라운드 색상
        self.tabBarController?.tabBar.backgroundColor = .white
    }
    
    override func viewWillLayoutSubviews() {
        profileImageViewHeight.constant = self.view.frame.height * 8 / 100
        soldViewHeight.constant = self.view.frame.height * 7 / 100
    
        profileImageView.layer.cornerRadius = profileImageView.frame.height * 0.5
        soldDetailView.layer.cornerRadius = soldDetailView.frame.height * 0.5
        boughtDetailView.layer.cornerRadius = boughtDetailView.frame.height * 0.5
        interestListView.layer.cornerRadius = interestListView.frame.height * 0.5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loginUserData = UserModel.getUserData()
        
        FirebaseManager.shared.downloadImagesTest(url: loginUserData?.profileImageUrl ?? "") { image in
         
            DispatchQueue.main.async {
                self.profileImageView.image = image == nil ? UIImage(named: "user") : image?.resizeThumbnailTo()
                self.myInfoTableView.reloadData()
            }
        }
        
        nicknameLabel.text = loginUserData?.nickname ?? ""
        regionLabel.text = loginUserData?.selectedAddress ?? ""
    }
    
    @IBAction func tapSoldDetailButton(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "myproductsListVC") as? MyProductsListViewController else { return }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func tapInterestDetailButton(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "interestVC") as? InterestViewController else { return }
        self.navigationController?.pushViewController(vc, animated: true)
        
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
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.section == 0 && indexPath.row == 0 {
//            guard let vc = storyboard?.instantiateViewController(withIdentifier: "profileVC") as? ProfileTableViewController else { return }
//            vc.userData = loginUserData
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//    }
}
