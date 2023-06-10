//
//  SettingViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/02/28.
//

import UIKit

// MARK: [Class or Struct] ----------
class SettingViewController: UIViewController {
    
    // MARK: [Override] ----------
    override func viewDidLoad() {
        super.viewDidLoad()

        let appearance = UINavigationBarAppearance()
        appearance.setBackIndicatorImage(UIImage(named: "backButton"), transitionMaskImage: UIImage(named: "backButton"))
        appearance.backgroundColor = .white
        self.navigationItem.standardAppearance = appearance
        self.navigationItem.scrollEdgeAppearance = appearance
    }
}

// MARK: [TableView - DataSource] ----------
extension SettingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "sectionCell") as? SettingSectionTableViewCell else { return UITableViewCell() }
            cell.titleLabel.text = "기타"
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell") as? SettingTitleTableViewCell else { return UITableViewCell() }
            cell.titleLabel.text = "로그아웃"
            return cell
        default:
            return UITableViewCell()
        }
    }
}

// MARK: [TableView - Delegate] ----------
extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 1:
            UserDefaults.standard.removeObject(forKey: "LoginUser")
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "LoginMainView") as? LoginViewController else { return }
            
            let navigationVC = UINavigationController(rootViewController: vc)
            
            UIApplication.shared.windows.first?.rootViewController = navigationVC
        default:
            print("default")
        }
    }
}
