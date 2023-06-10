//
//  BaseProfileMenuViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/02/10.
//

import UIKit

// MARK: [Class or Struct] ----------
class BaseProfileMenuViewController: UIViewController {

    // MARK: [@IBOutlet] ----------
    @IBOutlet var baseProfileMenuTableView: UITableView!
    
    // MARK: [Let Or Var] ----------
    var accessController = AccessControllerType.none
    
    var userData: UserModel?
    var profileImage = UIImage()
    
    // MARK: [Override] ----------
    override func viewDidLoad() {
        super.viewDidLoad()

        userData = accessController == .productDetailVC ? userData : UserModel.getUserData()
        
        configProfileData {
            DispatchQueue.main.async {
                self.baseProfileMenuTableView.reloadData()
            }
        }
        
        let appearance = UINavigationBarAppearance()
        appearance.setBackIndicatorImage(UIImage(named: "backButton"), transitionMaskImage: UIImage(named: "backButton"))
        
        appearance.backgroundColor = .white
        appearance.shadowColor = .systemGray4.withAlphaComponent(0)
    
        self.navigationItem.leftBarButtonItem?.tintColor = .black.withAlphaComponent(0)
        
        let leftTitleButton = UIBarButtonItem(title: "나의 당근", style: .plain, target: nil, action: nil)
        let attributes: [NSAttributedString.Key : Any] = [ .font: UIFont.boldSystemFont(ofSize: 20) ]
        
        leftTitleButton.setTitleTextAttributes(attributes, for: .normal)
        self.navigationItem.leftBarButtonItem = leftTitleButton
        self.navigationItem.leftBarButtonItem?.tintColor = .black.withAlphaComponent(0)

        self.navigationItem.standardAppearance = appearance
        self.navigationItem.scrollEdgeAppearance = appearance
    }
    
    // MARK: [@IBOutlet] ----------
    @IBAction func tapSettingButton(_ sender: Any) {
        
        
    }
    
    
    // MARK: [Function] ----------
    func configProfileData(completion: @escaping () -> ()) {
        FirebaseManager.shared.fetchUserData(phoneNumber: userData?.phoneNumber ?? "") { result in
            switch result {
            case .success(let userData):
                
                FirebaseManager.shared.downloadThumbnailImage(url: userData.profileImageUrl ?? "") { result in
                    switch result {
                    case .success(let image):
                        self.profileImage = image
                        completion()
                        
                    case .failure(let error):
                        print(error)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: [@objc Function] ----------
    @objc func tapShowProfileButton() {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "profileVC") as? ProfileViewController else { return }
        vc.userData = self.userData
        vc.profileImage = self.profileImage
        vc.rootVC = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: [TableView - DataSource] ----------
extension BaseProfileMenuViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 3
        case 2:
            return 3
        default:
            print("numberOfRowsInSection - default")
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell") as? ProfileTableViewCell else { return UITableViewCell() }
            cell.showProfileButton.addTarget(self, action: #selector(tapShowProfileButton), for: .touchUpInside)
            cell.profileImageView.image = profileImage.resizeThumbnailTo()
            cell.nicknameLabel.text = userData?.nickname ?? ""
            
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell") as? MenuTableViewCell else { return UITableViewCell() }
            
            switch indexPath.row {
            case 0:
                guard let titleCell = tableView.dequeueReusableCell(withIdentifier: "menuTitleCell") as? MenuTitleTableViewCell else { return UITableViewCell() }
                titleCell.menuTitleLabel.text = "나의 거래"
                titleCell.underlineView.isHidden = true
                return titleCell
            case 1:
                cell.menuNameLabel.text = "관심목록"
                cell.menuImageView.image = UIImage(systemName: "heart")
                return cell
            case 2:
                cell.menuNameLabel.text = "판매내역"
                cell.menuImageView.image = UIImage(systemName: "doc")
                return cell
            default:
                return UITableViewCell()
            }
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell") as? MenuTableViewCell else { return UITableViewCell() }
        
            switch indexPath.row {
            case 0:
                guard let titleCell = tableView.dequeueReusableCell(withIdentifier: "menuTitleCell") as? MenuTitleTableViewCell else { return UITableViewCell() }
                titleCell.menuTitleLabel.text = "기타"
                return titleCell
            case 1:
                cell.menuNameLabel.text = "내 동네 설정"
                cell.menuImageView.image = UIImage(systemName: "location.north.circle")
                return cell
            case 2:
                cell.menuNameLabel.text = "동네 인증하기"
                cell.menuImageView.image = UIImage(systemName: "scope")
                return cell
            default:
                return UITableViewCell()
            }
        default:
            print("cellForRowAt indexPath.section - default")
            return UITableViewCell()
        }
    }
}

// MARK: [TableView - Delegate] ----------
extension BaseProfileMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let storyboard = UIStoryboard(name: "Profile", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "profileVC") as? ProfileViewController else { return }
            vc.userData = self.userData
            vc.profileImage = self.profileImage
            vc.rootVC = self
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            switch indexPath.row {
            case 1:
                let storyboard = UIStoryboard(name: "LikeProducts", bundle: nil)
                guard let vc = storyboard.instantiateViewController(withIdentifier: "likeProductsVC") as? LikeProductsViewController else { return }
                self.navigationController?.pushViewController(vc, animated: true)
            case 2:
                let storyboard = UIStoryboard(name: "MoreSellerOtherProducts", bundle: nil)
                guard let vc = storyboard.instantiateViewController(withIdentifier: "MoreSellerOtherProductsVC") as? MoreSellerOtherProductsViewController else { return }
                vc.userData = self.userData
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                print("didSelectRowAt indexPath.row - default")
            }
        case 2:
            switch indexPath.row {
            case 1:
                let storyboard = UIStoryboard(name: "AddressSetting", bundle: nil)

                guard let vc = storyboard.instantiateViewController(withIdentifier: "addressSettingVC") as? AddressSettingViewController else { return }
                vc.accessController = .baseProfileVC
                let navigationVC = UINavigationController(rootViewController: vc)
                navigationVC.modalPresentationStyle = .fullScreen
                
                self.present(navigationVC, animated: true)
            case 2:
                let storyboard = UIStoryboard(name: "AddressAuth", bundle: nil)
                guard let vc = storyboard.instantiateViewController(withIdentifier: "addressAuthVC") as? AddressAuthViewController else { return }
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                print("didSelectRowAt indexPath.row - default")
            }
        default:
            print("didSelectRowAt indexPath.section - default")
        }
    }
}

// MARK: [Extention Delegate] ----------
extension BaseProfileMenuViewController: EditProfileViewControllerDelegate {
    func updateProfileData(nickname: String?, profileImage: UIImage?) { 
        if let cell = baseProfileMenuTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileTableViewCell {
        
            if nickname != nil && profileImage != nil {
                cell.profileImageView.image = profileImage
                cell.nicknameLabel.text = nickname
            } else if nickname == nil && profileImage != nil {
                cell.profileImageView.image = profileImage
            } else if nickname != nil && profileImage == nil {
                cell.nicknameLabel.text = nickname
            }
        }
        
        userData = UserModel.getUserData()
        
        FirebaseManager.shared.downloadThumbnailImage(url: userData?.profileImageUrl ?? "") { result in
            switch result {
            case .success(let image):
                self.profileImage = image
            case .failure(let error):
                print(error)
            }
        }
    }
}

// MARK: [ScrollView - Delegate] ----------
extension BaseProfileMenuViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
       
        let percentage = scrollView.contentOffset.y / 44
    
        if scrollView.contentOffset.y <= 0 {
            self.navigationItem.standardAppearance?.shadowColor = .systemGray4.withAlphaComponent(0)
            self.navigationItem.scrollEdgeAppearance?.shadowColor = .systemGray4.withAlphaComponent(0)
        } else {
            self.navigationItem.leftBarButtonItem?.tintColor = .black.withAlphaComponent(percentage)
            self.navigationItem.standardAppearance?.shadowColor = .systemGray4.withAlphaComponent(percentage)
            self.navigationItem.scrollEdgeAppearance?.shadowColor = .systemGray4.withAlphaComponent(percentage)
        }
    }
}
