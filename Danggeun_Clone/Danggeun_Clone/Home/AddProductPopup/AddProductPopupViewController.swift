//
//  AddProductPopupViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/01/28.
//

import UIKit

// MARK: [Class or Struct] ----------
class AddProductPopupViewController: UIViewController {

    // MARK: [@IBOutlet] ----------
    @IBOutlet var plusButton: UIButton!
    @IBOutlet var plusButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet var addProductButtonView: UIView!
    
    // MARK: [Let Or Var] ----------
    var tabbarHeight: CGFloat = 0.0
    
    // MARK: [Override] ----------
    override func viewDidLoad() {
        super.viewDidLoad()

        plusButtonBottomConstraint.constant += tabbarHeight
        
        plusButton.layer.cornerRadius = plusButton.frame.height / 2
        addProductButtonView.layer.cornerRadius = 10
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addProductButtonView.alpha = 0
    
        UIView.animateKeyframes(withDuration: 0.3, delay: 0) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3) {
                self.view.backgroundColor = .black.withAlphaComponent(0.5)
            }
            
            UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 2/3) {
                self.addProductButtonView.alpha = 1
            }
        }
    }
    
    // MARK: [@IBAction] ----------
    @IBAction func tapXButton(_ sender: Any) {
        dismiss(animated: false)
        
    }
    
    @IBAction func tapAddProductButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "AddProduct", bundle: nil)
        guard let homeVC = self.presentingViewController?.children.first?.children.first as? HomeViewController else { return }
        guard let vc = storyboard.instantiateViewController(withIdentifier: "addProductVC") as? AddProductViewController else { return }
        
        vc.homeDelegate = homeVC
        vc.accessController = .homeVC
        
        let navigationVC = UINavigationController(rootViewController: vc)
        navigationVC.modalPresentationStyle = .fullScreen
        
        
        self.dismiss(animated: false) {
            homeVC.present(navigationVC, animated: true)
        }
    }
}
