//
//  AddressPopupViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/02/07.
//

import UIKit

// MARK: [Protocol] ----------
protocol AddressPopupViewControllerDelegate: AnyObject {
    func rotationAddressButtonImageView()
    func fetchSelectedAddressProducts()
}

// MARK: [Class or Struct] ----------
class AddressPopupViewController: UIViewController {

    // MARK: [@IBOutlet] ----------
    @IBOutlet var addressListView: UIView!
    
    @IBOutlet var addressListViewLeading: NSLayoutConstraint!
    @IBOutlet var addressListViewTop: NSLayoutConstraint!
    
    @IBOutlet var firstAddressButton: UIButton!
    @IBOutlet var secondAddressButton: UIButton!
    
    // MARK: [Let Or Var] ----------
    var loginUserData = UserModel.getUserData()
    weak var delegate: AddressPopupViewControllerDelegate?
  
    // MARK: [Override] ----------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configAddressButtons()
        configLayout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    
        let insetX = (addressListView.frame.width / 2) - (addressListView.frame.width * 0.85)
        let insetY = (addressListView.frame.height / 2) - 44
        
        addressListViewLeading.constant = insetX + 15
        addressListViewTop.constant = -insetY
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addressListView.transform = CGAffineTransform(scaleX: 0, y: 0)
        addressListView.layer.anchorPoint = CGPoint(x: 0.15, y: 0.0)
        
        UIView.animate(withDuration: 0.3, delay: 0) {
            self.view.backgroundColor = .black.withAlphaComponent(0.5)
            
            self.addressListView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    

    // MARK: [@IBAction] ----------
    @IBAction func tapBackgroundButton(_ sender: Any) {
        
        UIView.animate(withDuration: 0.3, delay: 0) {
            self.view.backgroundColor = .black.withAlphaComponent(0)
            self.addressListView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.delegate?.rotationAddressButtonImageView()
        } completion: { _ in
            self.dismiss(animated: false)
            
        }
    }
    
    @IBAction func tapFirstAddressButton(_ sender: Any) {
      
        if loginUserData?.selectedAddress != loginUserData?.address1 {
            let address1 = loginUserData?.address1 ?? ""
            loginUserData?.selectedAddress = address1
            UserModel.saveUserData(userData: loginUserData)
            delegate?.fetchSelectedAddressProducts()
        }
        
        UIView.animate(withDuration: 0.3, delay: 0) {
            self.view.backgroundColor = .black.withAlphaComponent(0)
            self.addressListView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.delegate?.rotationAddressButtonImageView()
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }
    
    @IBAction func tapSecondAddressButton(_ sender: Any) {
        if loginUserData?.selectedAddress != loginUserData?.address2 {
            let address2 = loginUserData?.address2 ?? ""
            loginUserData?.selectedAddress = address2
            UserModel.saveUserData(userData: loginUserData)
            delegate?.fetchSelectedAddressProducts()
        }
        
        UIView.animate(withDuration: 0.3, delay: 0) {
            self.view.backgroundColor = .black.withAlphaComponent(0)
            self.addressListView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.delegate?.rotationAddressButtonImageView()
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }
    
    @IBAction func tapAddressSettingButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "AddressSetting", bundle: nil)
        guard let homeVC = self.presentingViewController?.children.first?.children.first as? HomeViewController else { return }
        guard let vc = storyboard.instantiateViewController(withIdentifier: "addressSettingVC") as? AddressSettingViewController else { return }
        vc.delegate = homeVC
        vc.accessController = .homeVC
        let navigationVC = UINavigationController(rootViewController: vc)
        navigationVC.modalPresentationStyle = .fullScreen
        
        self.dismiss(animated: false) {
            self.delegate?.rotationAddressButtonImageView()
            homeVC.present(navigationVC, animated: true)
        }
    }
    
    // MARK: [Function] ----------
    func configLayout() {
        addressListView.layer.cornerRadius = 5
    }
    
    func configAddressButtons() {
        let loginUserData = UserModel.getUserData()
        let firstAddress = loginUserData?.address1.components(separatedBy: " ").last ?? ""
        let secondAddress = loginUserData?.address2?.components(separatedBy: " ").last ?? ""
        
        firstAddressButton.setTitle(firstAddress, for: .normal)
        secondAddressButton.setTitle(secondAddress, for: .normal)
        
        let firstButtonColor: UIColor = loginUserData?.address1 == loginUserData?.selectedAddress ? .black : .lightGray
        firstAddressButton.setTitleColor(firstButtonColor, for: .normal)
        
        let secondButtonColor: UIColor = loginUserData?.address2 == loginUserData?.selectedAddress ? .black : .lightGray
        secondAddressButton.setTitleColor(secondButtonColor, for: .normal)
    }
}
