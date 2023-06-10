////
////  MyAddressPopupViewController.swift
////  Danggeun_Clone
////
////  Created by PKW on 2022/09/14.
////
//
//import UIKit
//import FirebaseFirestore
//
//protocol MyAddressPopupViewControllerDelegate: MainViewController {
//    // 동네 버튼 업데이트
//    func updateAddressButton()
//    
//    // 상품 업데이트
//    func fetchProducts()
//}
//
//class MyAddressPopupViewController: UIViewController {
//    
//    @IBOutlet var addressListView: UIView!
//
//    @IBOutlet var addressListViewCenterX: NSLayoutConstraint!
//    @IBOutlet var addressListViewCenterY: NSLayoutConstraint!
//    
//    @IBOutlet var backButton: UIButton!
//    
//    @IBOutlet var firstButton: UIButton!
//    @IBOutlet var secondButton: UIButton!
//    @IBOutlet var settingButton: UIButton!
//    
//    var addressButtonCenter: CGPoint?
//    var navigationHeight: Double?
//    
//    var userData: UserModel?
//    
//    weak var delegate: MyAddressPopupViewControllerDelegate?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
// 
//        userData = UserModel.getUserData()
//
//        addressListView.layer.cornerRadius = 5
//        
//        // 상태바 높이
//        guard let statusBarHeight = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets.top else { return }
//        
//        // center X,Y를 디바이스의 X = 0, Y = 0으로 초기화
//        // Y는 상태바 높이 + 네비게이션바 높이
//        // X는 +50
//        addressListViewCenterX.constant = -(UIScreen.main.bounds.width / 2) + 50
//        addressListViewCenterY.constant = -(UIScreen.main.bounds.height / 2) + statusBarHeight + (navigationHeight ?? 0.0) 
//        
//        firstButton.contentHorizontalAlignment = .left
//        secondButton.contentHorizontalAlignment = .left
//        settingButton.contentHorizontalAlignment = .left
//    
//        setupAddressButton()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//          
//        self.addressListView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
//        self.addressListView.layer.anchorPoint = CGPoint(x: 0.2, y: 0.0)
//        
//        UIView.animate(withDuration: 0.5, delay: 0) {
//            self.addressListView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
//            self.backButton.alpha = 0.5
//        }
//    }
//    
//    func setupAddressButton() {
//        firstButton.setTitle("\(userData?.address1.components(separatedBy: " ").last ?? "")", for: .normal)
//        secondButton.setTitle("\(userData?.address2?.components(separatedBy: " ").last ?? "")", for: .normal)
//        firstButton.tintColor = userData?.address1 ?? "" == userData?.selectedAddress ?? "" ? .black : .lightGray
//        secondButton.tintColor = userData?.address2 ?? "" == userData?.selectedAddress ?? "" ? .black : .lightGray
//    }
//    
//    @IBAction func tapCloseButton(_ sender: Any) {
//        
//        guard let rootVC = delegate else { return }
//        
//        UIView.animate(withDuration: 0.5, delay: 0) {
//            rootVC.navigationTitleView.addressButton.imageView?.transform = .identity
//            self.addressListView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
//            self.backButton.alpha = 0.0
//        } completion: { _ in
//            self.dismiss(animated: false)
//        }
//    }
//    
//    // 첫번째 버튼 터치
//    @IBAction func tapFirstAddressButton(_ sender: Any) {
//    
//        guard let rootVC = delegate else { return }
//        
//        if !rootVC.isFetching && !rootVC.isPaging && !rootVC.isRefresh {
//            
//            guard var userData = userData else { return }
//            
//            userData.selectedAddress = userData.address1
//            UserModel.saveUserData(userData: userData)
//            
//            FirebaseManager.shared.updateAddressData(userPhoneNumber: userData.phoneNumber ?? "", data: ["selectedAddress" : userData.address1]) {
//                
//                rootVC.updateAddressButton()
//                rootVC.fetchProducts()
//                
//                self.tapCloseButton(sender)
//            }
//        } else {
//            return
//        }
//    }
//    
//    // 두번째 버튼 터치
//    @IBAction func tapSecondAddressButton(_ sender: Any) {
//        
//        guard let rootVC = delegate else { return }
//        
//        if !rootVC.isFetching && !rootVC.isPaging && !rootVC.isRefresh {
//            
//            guard var userData = userData else { return }
//            
//            userData.selectedAddress = userData.address2 ?? ""
//            UserModel.saveUserData(userData: userData)
//            
//            FirebaseManager.shared.updateAddressData(userPhoneNumber: userData.phoneNumber ?? "", data: ["selectedAddress" : userData.address2 ?? ""]) {
//                
//                rootVC.updateAddressButton()
//                rootVC.fetchProducts()
//                
//                self.tapCloseButton(sender)
//            }
//        } else {
//            return
//        }
//    }
//    
//    // 내 동네 설정하기 버튼 누르면 동네 설정하는 창으로 이동
//    @IBAction func tapSettingAddressButton(_ sender: Any) {
//        
//        guard let rootVC = self.delegate else { return }
//        guard let nvc = self.storyboard?.instantiateViewController(withIdentifier: "settingNavigationVC") as? UINavigationController else { return }
//        guard let vc = nvc.children.first as? SettingAddressViewController else { return }
//        
//        // 닫기 전에 화살표 원위치
//        UIView.animate(withDuration: 0.5, delay: 0) {
//            rootVC.navigationTitleView.addressButton.imageView?.transform = .identity
//        }
//        
//        self.dismiss(animated: false) {
//            nvc.modalPresentationStyle = .overFullScreen
//            vc.delegate = self.delegate
//            rootVC.present(nvc, animated: true)
//        }
//    }
//}
