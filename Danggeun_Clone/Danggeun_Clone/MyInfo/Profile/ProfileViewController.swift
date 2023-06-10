//
//  ProfileViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/02/10.
//

import UIKit

// MARK: [Class or Struct] ----------
class ProfileViewController: UIViewController {

    // MARK: [@IBOutlet] ----------
    @IBOutlet var profileTableView: UITableView!
    
    // MARK: [Let Or Var] ----------
    var userData: UserModel?
    var profileImage: UIImage?
    
    weak var rootVC: BaseProfileMenuViewController?

    // MARK: [Override] ----------
    override func viewDidLoad() {
        super.viewDidLoad()

        let appearance = UINavigationBarAppearance()
        appearance.setBackIndicatorImage(UIImage(named: "backButton"), transitionMaskImage: UIImage(named: "backButton"))
        appearance.backgroundColor = .white
        self.navigationItem.standardAppearance = appearance
        self.navigationItem.scrollEdgeAppearance = appearance
        
        FirebaseManager.shared.fetchOtherProductsCount(phoneNumber: userData?.phoneNumber ?? "") { result in
            switch result {
            case .success(let count):
                self.userData?.productsCount = count
                
                DispatchQueue.main.async {
                    self.profileTableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
                }
                                                          
            case .failure(let error):
                print("Error", error)
            }
        }
    }

    // MARK: [@objc Function] ----------
    @objc func tapEditProfileButton() {
        let storyboard = UIStoryboard(name: "EditProfile", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "editProfile") as? EditProfileViewController else { return }
        vc.editProfileViewDelegate1 = rootVC
        vc.editProfileViewDelegate2 = self
        vc.userData = self.userData
        vc.profileImage = self.profileImage
        self.present(vc, animated: true)
    }
}

// MARK: [TableView - DataSource] ----------
extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        switch indexPath.row {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as? ProfileDataTableViewCell else { return UITableViewCell() }
            cell.profileImageView.image = profileImage == nil ? UIImage(named: "user") : profileImage
            cell.nicknameLabel.text = userData?.nickname ?? ""
            cell.editProfileButton.addTarget(self, action: #selector(tapEditProfileButton), for: .touchUpInside)
            cell.editProfileButton.isHidden = UserModel.getUserData()?.phoneNumber ?? "" == userData?.phoneNumber ?? "" ? false : true
            
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "myProductsCell", for: indexPath) as? MyProductsTableViewCell else { return UITableViewCell() }
            
            let totalCount = userData?.productsCount?["total"] ?? 0
            let hiddenCount = userData?.productsCount?["hidden"] ?? 0
            
            cell.productsCountLabel.text = "판매상품 \(totalCount - hiddenCount)개"
            return cell
        default:
            print("cellForRowAt - default")
            return UITableViewCell()
        }
    }
}

// MARK: [TableView - Delegate] ----------
extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 1:
            let storyboard = UIStoryboard(name: "MoreSellerOtherProducts", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "MoreSellerOtherProductsVC") as? MoreSellerOtherProductsViewController else { return }
            vc.userData = userData
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            print("default")
        }
    }
}

// MARK: [Delegate] ----------
extension ProfileViewController: EditProfileViewControllerDelegate {
    func updateProfileData(nickname: String?, profileImage: UIImage?) {
        if let cell = profileTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileDataTableViewCell {
            
            if nickname != nil && profileImage != nil {
                cell.profileImageView.image = profileImage
                cell.nicknameLabel.text = nickname
            } else if nickname == nil && profileImage != nil {
                cell.profileImageView.image = profileImage
            } else if nickname != nil && profileImage == nil {
                cell.nicknameLabel.text = nickname
            }
        }
    }
}
