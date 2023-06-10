//
//  HomeViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/01/13.
//

import UIKit
import Kingfisher
import SnapKit

// MARK: [Class or Struct] ----------
class HomeViewController: UIViewController {
    
    // MARK: [@IBOutlet] ----------
    @IBOutlet var productListTableView: UITableView!
    @IBOutlet var indicatorView: UIActivityIndicatorView!

    @IBOutlet var plusButton: UIButton!
    
    // MARK: [Let Or Var] ----------
    lazy var refreshControl: UIRefreshControl = { [weak self] in
        let control = UIRefreshControl()
        return control
    }()
    
    let navigationTitleView = MyAddressButtonView()
    
    var loginUserData = UserModel.getUserData()
    var productList = [ProductRegistrationModel]()
    
    var isPaging = false

    // MARK: [Override] ----------
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setup()
        configMyAddressButton()
        configLayout()
       
        self.indicatorView.isHidden = false
        indicatorView.startAnimating()
        FirebaseManager.shared.fetchProducts(address: loginUserData?.selectedAddress ?? "") { result in
            switch result {
            case .success(let products):
                self.productList = products

                DispatchQueue.main.async {
                    print("상품 데이터 다 가지고옴")
                    self.indicatorView.stopAnimating()
                    self.indicatorView.isHidden = true
                    self.productListTableView.reloadData()
                }

            case .failure(let error):
                // 에러처리 할거
                print(error)
            }
        }
    }
    
    // MARK: [@IBAction] ----------
    @IBAction func tapPlusButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "AddProductPopup", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "addProductPopupVC") as? AddProductPopupViewController else { return }
        vc.tabbarHeight = self.tabBarController?.tabBar.frame.height ?? 0.0
        self.present(vc, animated: false)
    }
    
    @IBAction func dummyData(_ sender: Any) {
        
        var timer: DispatchSourceTimer?
        var count = 0
        
        timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
        timer?.schedule(deadline: .now(), repeating: 5)
        
        FirebaseManager.shared.updateDummyData { data in
            
            timer?.resume()
            
            timer?.setEventHandler(handler: {
                
                if count == 149 {
                    timer?.cancel()
                    timer = nil
                    print("끝")
                }
                
                let productData = [
                    "title": data[count].title,
                    "contents": data[count].content,
                    "price": data[count].price,
                    "category": data[count].category,
                    "phoneNumber": data[count].phoneNumber ?? "",
                    "address": data[count].address ?? "",
                    "hidden": data[count].hidden,
                    "status": data[count].status,
                    "reservation": data[count].reservation] as [String: Any]
                
                let image = UIImage(named: data[count].images[0]) ?? UIImage()
                
                FirebaseManager.shared.addDummyProduct(address: data[count].address ?? "", productData: productData, selectedImages: [image]) { result in
                    switch result {
                    case .success(let bool):
                        print(bool)
                    case .failure(let error):
                        print(error)
                    }
                }
                print("시작", count)
                count += 1
            })
        }
    }
    
    
    
    
    // MARK: [Function] ----------
    func setup() {
        let nibName = UINib(nibName: "ProductTableViewCell", bundle: nil)
        productListTableView.register(nibName, forCellReuseIdentifier: "productCell")
        
        productListTableView.prefetchDataSource = self
        
        productListTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadProducts), name: .reloadMainViewProducts, object: nil)
    }
    
    func configLayout() {
        plusButton.layer.cornerRadius = plusButton.frame.height / 2
    }
    
    func configMyAddressButton() {
        
        FirebaseManager.shared.getUserData(userPhoneNumber: loginUserData?.phoneNumber ?? "" , completion: { userData in
            self.loginUserData = userData
            
            UserModel.saveUserData(userData: self.loginUserData)
                
            self.navigationTitleView.addressButton.setTitle(self.loginUserData?.selectedAddress.components(separatedBy: " ").last ?? "", for: .normal)
            self.navigationTitleView.addressButton.addTarget(self, action: #selector(self.tapAddressButton), for: .touchUpInside)
            self.navigationTitleView.addressButton.layoutIfNeeded()
        
            self.navigationItem.titleView = self.navigationTitleView
        })
    }
    
    
    // MARK: [@objc Function] ----------
    @objc func reloadProducts() {
        loginUserData = UserModel.getUserData()
        
        navigationTitleView.addressButton.setTitle(loginUserData?.selectedAddress.components(separatedBy: " ").last ?? "", for: .normal)
        
        indicatorView.isHidden = false
        indicatorView.startAnimating()
        FirebaseManager.shared.fetchProducts(address: loginUserData?.selectedAddress ?? "") { result in
            switch result {
            case .success(let products):
                self.productList = products

                DispatchQueue.main.async {
                    print("상품 데이터 다 가지고옴")
                    self.indicatorView.stopAnimating()
                    self.indicatorView.isHidden = true
                    self.productListTableView.reloadData()
                }

            case .failure(let error):
                // 에러처리 할거
                print(error)
            }
        }
    }
    
    @objc func refresh() {
        indicatorView.isHidden = false
        indicatorView.startAnimating()
        DispatchQueue.global().async {
            FirebaseManager.shared.resetProductsDownloadData(isCategory: false) {
                FirebaseManager.shared.fetchProducts(address: self.loginUserData?.selectedAddress ?? "") { result in
                    switch result {
                    case .success(let products):
                        self.productList.removeAll()
                        self.productList = products
                        
                        DispatchQueue.main.async {
                            self.productListTableView.reloadData()
                            self.productListTableView.refreshControl?.endRefreshing()
                            self.indicatorView.isHidden = true
                            self.indicatorView.stopAnimating()
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
    
    @objc func tapAddressButton() {
        
        loginUserData = UserModel.getUserData()
        
        if loginUserData?.address1 != "" && loginUserData?.address2 == "" {
    
            let storyboard = UIStoryboard(name: "AddressSetting", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "addressSettingVC") as? AddressSettingViewController else { return }
            vc.delegate = self
            
            let navigationVC = UINavigationController(rootViewController: vc)
            navigationVC.modalPresentationStyle = .fullScreen
            
            self.present(navigationVC, animated: true)
            
        } else if loginUserData?.address1 != "" && loginUserData?.address2 != "" {
        
            UIView.animate(withDuration: 0.3, delay: 0) {
                self.navigationTitleView.addressButton.imageView?.transform = CGAffineTransform(rotationAngle: 180 * .pi / 180)
            }
            
            let storyboard = UIStoryboard(name: "AddressPopup", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "addressPopupVC") as? AddressPopupViewController else { return }
            vc.delegate = self
            self.present(vc, animated: false)
        }
    }
}

// MARK: [TableView - DataSourcePrefetching] ----------
extension HomeViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {

        for indexPath in indexPaths {

            if productList[indexPath.row].ThumbnailImage != nil {
                continue
            }

            let targetUrl = productList[indexPath.row].imagesURL.first ?? ""
            FirebaseManager.shared.downloadThumbnailImage(url: targetUrl) { result in

                switch result {
                case .success(let image):
                    self.productList[indexPath.row].ThumbnailImage = image
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            
            if let targetUrl = URL(string: productList[indexPath.row].imagesURL.first ?? "") {
                KingfisherManager.shared.downloader.cancel(url: targetUrl)
            }
        }
    }
}

// MARK: [TableView - DataSource] ----------
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as? ProductTableViewCell else { return UITableViewCell() }
        
        let target = productList[indexPath.row]
        
        cell.titleLabel.text = target.title
        cell.addressLabel.text = target.address?.components(separatedBy: " ").last ?? ""
        cell.timeLabel.text = "\(target.update.convertTimestamp()) 전"
        cell.priceLabel.text = "\(target.price.insertComma)원"
        
        if target.status == ProductStatusType.completed.rawValue {
            cell.finishedLabel.isHidden = false
        } else if target.isReservation == true {
            cell.reservationLabel.isHidden = false
        }
        
        if target.likeCount == nil || target.likeCount == 0 {
            cell.chatAndLikeStackView.isHidden = true
        } else {
            cell.chatAndLikeStackView.isHidden = false
            cell.likeCountLabel.text = "\(target.likeCount ?? 0)"
        }
        
        if let imageUrl = URL(string: target.imagesURL.first ?? "") {
            let options: KingfisherOptionsInfo = [.transition(.fade(0.2)), .cacheOriginalImage]
            cell.productImageView.kf.setImage(with: imageUrl, options: options)
        } else {
            cell.productImageView.image = UIImage()
        }
        
        
//        if let image = target.ThumbnailImage {
//            cell.productImageView.image = image
//        } else {
//            cell.productImageView.image = nil
//
//            let targetUrl = target.imagesURL.first ?? ""
//
//            FirebaseManager.shared.downloadThumbnailImage(url: targetUrl) { result in
//
//                switch result {
//                case .success(let image):
//                    self.productList[indexPath.row].ThumbnailImage = image
//
//                    let reloadTargetIndexPath = IndexPath(row: indexPath.row, section: 0)
//
//                    DispatchQueue.main.async {
//                        self.productListTableView.reloadRows(at: [reloadTargetIndexPath], with: .automatic)
//                    }
//
//                case .failure(let error):
//                    print(error)
//                }
//            }
//        }
        return cell
    }
}

// MARK: [TableView - Delegate] ----------
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "ProductDetail", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "ProductDetailVC") as? ProductDetailViewController else { return }
        vc.productData = productList[indexPath.row]
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: [ScrollView - Delegate] ----------
extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let tableViewHeight = scrollView.frame.height
        
        if offsetY > (contentHeight - tableViewHeight - UIScreen.main.bounds.height * 0.4) {
        
            if isPaging == false && FirebaseManager.shared.productsHasNextPage {
                isPaging = true
                FirebaseManager.shared.pagingProducts { result in
                    switch result {
                    case .success(let products):
            
                        self.productList.append(contentsOf: products)
                        self.isPaging = false
                        
                        DispatchQueue.main.async {
                            self.productListTableView.reloadData()
                            print("리로드 --------------------------------------")
                        }
                        
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
}

// MARK: [Extention Delegate] ----------
extension HomeViewController: AddressPopupViewControllerDelegate {
    func rotationAddressButtonImageView() {
        UIView.animate(withDuration: 0.3, delay: 0) {
            self.navigationTitleView.addressButton.imageView?.transform = .identity
        }
    }
    
    func fetchSelectedAddressProducts() {
        reloadProducts()
    }
}

extension HomeViewController: AddressSettingViewControllerDelegate {
    func fetchProducts() {
        
        loginUserData = UserModel.getUserData()
        
        navigationTitleView.addressButton.setTitle(loginUserData?.selectedAddress.components(separatedBy: " ").last ?? "", for: .normal)
        navigationTitleView.addressButton.layoutIfNeeded()
        
        self.indicatorView.isHidden = false
        self.indicatorView.startAnimating()
        FirebaseManager.shared.fetchProducts(address: loginUserData?.selectedAddress ?? "") { result in
            switch result {
            case .success(let products):
                self.productList.removeAll()
                
                self.productList = products

                DispatchQueue.main.async {
                    print("상품 데이터 다 가지고옴")
                    self.indicatorView.stopAnimating()
                    self.indicatorView.isHidden = true
                    self.productListTableView.reloadData()
                }
            case .failure(let error):
                // 에러처리 할거
                print(error)
            }
        }
    }
}

extension HomeViewController: AddProductViewControllerDelegate {
    func fetchAddProduct() {
        refresh()
    }
    
    func fetchDetailProductData(productData: [String: Any], images: [UIImage]) {}
}

extension HomeViewController: ProductDetailViewControllerDelegate {
    func fetchProductAfterDelete() {
        refresh()
    }
}



