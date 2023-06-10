//
//  AddressAuthViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/11/10.
//

import UIKit

class AddressAuthPopupViewController: UIViewController {

    // MARK: [@IBOutlet] ----------
    @IBOutlet var visualView: UIView!
    @IBOutlet var popupView: UIView!
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var authButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    
    // MARK: [Let Or Var] ----------
//    var rootView: ProductRegistraionViewController?
    var isFirst = false
    var addressName = ""
    
    // MARK: [Override] ----------
    override func viewDidLoad() {
        super.viewDidLoad()
            
        titleLabel.text = "이 기능을 사용하려면 \(addressName.components(separatedBy: " ").last ?? "")의 동네인증이 필요해요."
        
        configLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.visualView.alpha = 0.5
            self.popupView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }
    }

    
    @IBAction func tapBackgroundButton(_ sender: Any) {
        UIView.animate(withDuration: 0.2) {
            self.visualView.alpha = 0.0
            self.popupView.alpha = 0.0
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }
    
    @IBAction func tapAuthButton(_ sender: Any) {
       
//        guard let vc = storyboard?.instantiateViewController(withIdentifier: "addressAuthVC") as? AddressAuthViewController1 else { return }
//
//        self.dismiss(animated: false) {
//            self.rootView?.navigationController?.pushViewController(vc, animated: true)
//        }
    }
    
    @IBAction func tapCancelButton(_ sender: Any) {
//        UIView.animate(withDuration: 0.2) {
//            self.visualView.alpha = 0.0
//            self.popupView.alpha = 0.0
//        } completion: { _ in
//            if self.isFirst { // 처음 진입이면 루트뷰까지 dismiss
//                self.dismiss(animated: false) {
//                    self.rootView?.dismiss(animated: true)
//                }
//            } else {
//                self.dismiss(animated: false)
//            }
//        }
    }
    
    func configLayout() {
        popupView.layer.cornerRadius = 10
        authButton.layer.cornerRadius = 5
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.cornerRadius = 5
        cancelButton.layer.borderColor = UIColor.systemGray4.cgColor
    }
}
