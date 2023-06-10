//
//  ChangeAddressPopupViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/11/14.
//

import UIKit

// MARK: [Protocol] ----------
protocol ChangeAddressPopupViewControllerDelegate: AnyObject {
    func changeSelectedAddress(currentAddress: String)
}

// MARK: [Class or Struct] ----------
class ChangeAddressPopupViewController: UIViewController {

    // MARK: [@IBOutlet] ----------
    @IBOutlet var addressButton: UIButton!
    
    @IBOutlet var popupView: UIView!
    @IBOutlet var changeButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    
    // MARK: [Let Or Var] ----------
    weak var delegate: ChangeAddressPopupViewControllerDelegate?
    
    var currentAddress = ""
    var isSelected = true
    
    // MARK: [Override] ----------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configData()
        configLayout()
    }
    
    // MARK: [@IBAction] ----------
    @IBAction func tabAddressButton(_ sender: Any) {
        
        isSelected.toggle()
        
        if isSelected {
            addressButton.tintColor = .orange
            addressButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        } else {
            addressButton.tintColor = .gray
            addressButton.setImage(UIImage(systemName: "circle"), for: .normal)
        }
    }
    
    @IBAction func tapDoneButton(_ sender: Any) {
        delegate?.changeSelectedAddress(currentAddress: currentAddress)
        self.dismiss(animated: false)
    }
    
    @IBAction func tapCancelButton(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    // MARK: [Function] ----------
    func configData() {
        addressButton.setTitle("  \(currentAddress.components(separatedBy: " ").last ?? "")", for: .normal)
    }
    
    func configLayout() {
        popupView.layer.cornerRadius = 10
        changeButton.layer.cornerRadius = 5
        cancelButton.layer.cornerRadius = 5
    }
}
