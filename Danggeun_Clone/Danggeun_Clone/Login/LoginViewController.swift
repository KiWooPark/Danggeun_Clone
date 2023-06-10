//
//  LoginViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/10/08.
//

import UIKit

// MARK: [Class or Struct] ----------

class LoginViewController: UIViewController {
    
    // MARK: [@IBOutlet] ---
    @IBOutlet var startButton: UIButton!
    
    // MARK: [Override] ---
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        LocationManager.shared.checkLocationServicesEnabled()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "start" {
            guard let vc = segue.destination as? AddressListViewController else { return }
            vc.vcType = VCType.loginVC

        } else if segue.identifier == "login" {
            guard let vc = segue.destination as? AuthPhoneNumberViewController else { return }
            vc.vcType = VCType.loginVC
        }
    }
}


