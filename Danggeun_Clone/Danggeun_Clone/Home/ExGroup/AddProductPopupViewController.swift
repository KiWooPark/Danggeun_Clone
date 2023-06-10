//
//  AddProductPopupViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/06/07.
//

import UIKit

class AddProductPopupViewController: UIViewController {

    @IBOutlet var visualView: UIView!
    @IBOutlet var plusButton: UIButton!
    @IBOutlet var addProductView: UIView!
    @IBOutlet var addProductButton: UIView!
    
    @IBOutlet var plusButtonBottomConstraint: NSLayoutConstraint!
    
    var tabBarHeight: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        plusButtonBottomConstraint.constant = (tabBarHeight ?? 0.0) + 20 + 1
        
        plusButton.layer.cornerRadius = plusButton.frame.width * 0.5
        addProductView.layer.cornerRadius = 10
       
        addProductView.alpha = 0
        plusButton.alpha = 0
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.2) {
            self.visualView.alpha = 0.5
            self.plusButton.alpha = 1.0
            self.addProductView.alpha = 1.0
        }
    }

    @IBAction func tapBackgroundButton(_ sender: Any) {

        UIView.animate(withDuration: 0.2) {
            self.visualView.alpha = 0.0
            self.plusButton.alpha = 0.0
            self.addProductView.alpha = 0.0
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }
    
    @IBAction func tapAddProductButton(_ sender: Any) {

        guard let pvc = self.presentingViewController else { return }

        guard let vc = storyboard?.instantiateViewController(withIdentifier: "addProductNavigationVC") else { return }
        
        self.dismiss(animated: false) {
          pvc.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func tapPlusButton(_ sender: Any) {
        UIView.animate(withDuration: 0.2) {
            self.visualView.alpha = 0.0
            self.plusButton.alpha = 0.0
            self.addProductView.alpha = 0.0
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }
}
