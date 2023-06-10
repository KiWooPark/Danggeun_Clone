//
//  ThirdViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/01/20.
//

import UIKit
import FirebaseFirestore
import Kingfisher

// MARK: [Class or Struct] ----------
class ThirdViewController: UIViewController {
    
    // MARK: [@IBOutlet] ----------
    @IBOutlet var thirdTableView: UITableView!
    
    // MARK: [Let Or Var] ----------
    lazy var refreshControl: UIRefreshControl = { [weak self] in
        let control = UIRefreshControl()
        return control
    }()
    
    weak var innerTableViewDelegate: InnerTableViewScrollDelegate?
    
    private var oldContentOffset = CGPoint.zero
    
    var isPaging = false
    
    var userPhoneNumber = ""
    
    var products = [ProductRegistrationModel]()
    
    var showProductStatus = ProductStatusType.trading
    
    // MARK: [Override] ----------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nibName = UINib(nibName: "ProductTableViewCell", bundle: nil)
        thirdTableView.register(nibName, forCellReuseIdentifier: "productCell")
        
        thirdTableView.prefetchDataSource = self
        
        thirdTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        configProductsData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateHiddenProduct), name: .updateHiddenProduct, object: nil)
    }
    
    // MARK: [Function] ----------
    func configProductsData() {
        
        showProductStatus = UserModel.getUserData()?.phoneNumber ?? ""  == userPhoneNumber ? .hidden : .completed
        
        FirebaseManager.shared.fetchAllOrTradingOrCompletedOtherProducts(phoneNumber: userPhoneNumber, status: showProductStatus) { result in
            switch result {
            case .success(let products):
                self.products.removeAll()
                self.products = products
                
                DispatchQueue.main.async {
                    self.thirdTableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: [@objc Function] ----------
    @objc func tapHiddenButton(button: UIButton) {
        FirebaseManager.shared.updateHiddenProduct(id: self.products[button.tag].productId, address: self.products[button.tag].address ?? "", isHidden: false, status: self.products[button.tag].status) {
            
            self.configProductsData()
            NotificationCenter.default.post(name: .updateProductsCount, object: nil)
            NotificationCenter.default.post(name: .reloadMainViewProducts, object: nil)
            
            if self.products[button.tag].status == ProductStatusType.trading.rawValue {
                NotificationCenter.default.post(name: .updateTradingProduct, object: nil)
            } else {
                NotificationCenter.default.post(name: .updateCompletedProduct, object: nil)
            }
        }
    }
    
    @objc func updateHiddenProduct() {
        refresh()
    }
    
    @objc func tapMoreMenuButton(button: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let edit = UIAlertAction(title: "게시글 수정", style: .default) { _ in
            let storyboard = UIStoryboard(name: "AddProduct", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "addProductVC") as? AddProductViewController else { return }
            vc.productData = self.products[button.tag]
            vc.accessController = .moreProductsVC
            let navigationVC = UINavigationController(rootViewController: vc)
            navigationVC.modalPresentationStyle = .fullScreen
            self.present(navigationVC, animated: true)
        }
      
        let delete = UIAlertAction(title: "삭제", style: .destructive) { _ in
            FirebaseManager.shared.deleteProduct(id: self.products[button.tag].productId, phoneNumber: self.products[button.tag].phoneNumber, address: self.products[button.tag].address ?? "", status: self.products[button.tag].status) { result in
        
                self.configProductsData()
                NotificationCenter.default.post(name: .updateProductsCount, object: nil)
                NotificationCenter.default.post(name: .reloadMainViewProducts, object: nil)
            }
        }
        
        let close = UIAlertAction(title: "닫기", style: .cancel)
        
        alert.addAction(edit)
        alert.addAction(delete)
        alert.addAction(close)
        
        self.present(alert, animated: true)
        
    }
    
    @objc func refresh() {
        DispatchQueue.global().async {
            FirebaseManager.shared.resetOtherProductsDownloadData(status: .completed) {
                FirebaseManager.shared.fetchAllOrTradingOrCompletedOtherProducts(phoneNumber: self.userPhoneNumber, status: self.showProductStatus) { result in
                    switch result {
                    case .success(let products):
                        self.products.removeAll()
                        self.products = products
                        
                        NotificationCenter.default.post(name: .updateProductsCount, object: nil)
                        
                        DispatchQueue.main.async {
                            self.thirdTableView.reloadData()
                            self.thirdTableView.refreshControl?.endRefreshing()
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
}

// MARK: [TableView - DataSourcePrefetching] ----------
extension ThirdViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            
            if products[indexPath.row].ThumbnailImage != nil {
                continue
            }
            
            let targetUrl = products[indexPath.row].imagesURL.first ?? ""
            FirebaseManager.shared.downloadThumbnailImage(url: targetUrl) { result in
            
                switch result {
                case .success(let image):
                    self.products[indexPath.row].ThumbnailImage = image
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let targetUrl = URL(string: products[indexPath.row].imagesURL.first ?? "")!
            KingfisherManager.shared.downloader.cancel(url: targetUrl)
        }
    }
}

// MARK: [TableView - DataSource] ----------
extension ThirdViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if showProductStatus == .completed {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as? ProductTableViewCell else { return UITableViewCell() }
            
            let target = products[indexPath.row]
            
            cell.titleLabel.text = target.title
            cell.addressLabel.text = target.address?.components(separatedBy: " ").last ?? ""
            cell.timeLabel.text = "\(target.update.convertTimestamp()) 전"
            cell.priceLabel.text = "\(target.price.insertComma)원"
            
            if target.likeCount == nil || target.likeCount == 0 {
                cell.chatAndLikeStackView.isHidden = true
            } else {
                cell.chatAndLikeStackView.isHidden = false
                cell.likeCountLabel.text = "\(target.likeCount ?? 0)"
            }
            
            if products[indexPath.row].status == "completed" {
                cell.finishedLabel.isHidden = false
            }
            
            if let image = products[indexPath.row].ThumbnailImage {
                cell.productImageView.image = image
            } else {
                cell.productImageView.image = nil
                
                let targetUrl = products[indexPath.row].imagesURL.first ?? ""
                
                FirebaseManager.shared.downloadThumbnailImage(url: targetUrl) { result in
                                
                    switch result {
                    case .success(let image):
                        self.products[indexPath.row].ThumbnailImage = image
                        
                        let reloadTargetIndexPath = IndexPath(row: indexPath.row, section: 0)
                        
                        DispatchQueue.main.async {
                            self.thirdTableView.reloadRows(at: [reloadTargetIndexPath], with: .automatic)
                        }
                        
                    case .failure(let error):
                        print(error)
                    }
                }
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "hiddenCell") as? HiddenProductTableViewCell else { return UITableViewCell() }
            
            cell.titleLabel.text = products[indexPath.row].title
            cell.addressLabel.text = products[indexPath.row].address ?? ""
            cell.timeLabel.text =  "\(products[indexPath.row].update.convertTimestamp()) 전"
            cell.priceLabel.text = "\(products[indexPath.row].price.insertComma)원"
            
            if products[indexPath.row].status == ProductStatusType.completed.rawValue {
                cell.completedLabel.isHidden = false
            } else if products[indexPath.row].isReservation == true {
                cell.reservationLabel.isHidden = false
            }
            
            if products[indexPath.row].likeCount == nil || products[indexPath.row].likeCount == 0 {
                cell.likeCountStackView.isHidden = true
            } else {
                cell.likeCountStackView.isHidden = false
                cell.likeCountLabel.text = "\(products[indexPath.row].likeCount ?? 0)"
            }
        
            cell.moreMenuButton.tag = indexPath.row
            cell.moreMenuButton.addTarget(self, action: #selector(tapMoreMenuButton), for: .touchUpInside)
            cell.hiddenButton.tag = indexPath.row
            cell.hiddenButton.addTarget(self, action: #selector(tapHiddenButton), for: .touchUpInside)
            
            if let image = products[indexPath.row].ThumbnailImage {
                cell.productImageView.image = image
            } else {
                cell.productImageView.image = nil

                let targetUrl = products[indexPath.row].imagesURL.first ?? ""

                FirebaseManager.shared.downloadThumbnailImage(url: targetUrl) { result in

                    switch result {
                    case .success(let image):

                        self.products[indexPath.row].ThumbnailImage = image

                        let reloadTargetIndexPath = IndexPath(row: indexPath.row, section: 0)

                        DispatchQueue.main.async {
                            self.thirdTableView.reloadRows(at: [reloadTargetIndexPath], with: .automatic)
                        }

                    case .failure(let error):
                        print(error)
                    }
                }
            }
            
            return cell
        }
    }
}

// MARK: [TableView - Delegate] ----------
extension ThirdViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "ProductDetail", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "ProductDetailVC") as? ProductDetailViewController else { return }
        vc.productData = products[indexPath.row]

        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: [ScrollView - Delegate] ----------
extension ThirdViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let y = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let tableViewHeight = scrollView.frame.height
        
        let hasNextPage = showProductStatus == .completed ? FirebaseManager.shared.completedOtherProductHasNextPage : FirebaseManager.shared.hiddenOtherProductHasNextPage
        
        if y > (contentHeight - tableViewHeight - UIScreen.main.bounds.height * 0.3) {
            if isPaging == false && hasNextPage {
                self.isPaging = true
                
                let status = showProductStatus == .completed ? ProductStatusType.completed : ProductStatusType.hidden
                
                FirebaseManager.shared.pagingAllOrTradingOrCompletedOtherProducts(phoneNumber: userPhoneNumber, status: status) { result in
                    switch result {
                    case .success(let products):
                        self.products.append(contentsOf: products)
                        self.isPaging = false
                        
                        DispatchQueue.main.async {
                            self.thirdTableView.reloadData()
                        }
                        
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
        
        let offsetY = scrollView.contentOffset.y - oldContentOffset.y
        
        let headerViewHeightConstant = innerTableViewDelegate?.headerHeight
        
        if let headerViewHeightConstant = headerViewHeightConstant {
            
            if offsetY > 0, headerViewHeightConstant > topViewHeightConstraintRange.lowerBound, scrollView.contentOffset.y > 0 {
                innerTableViewDelegate?.didScroll(distance: offsetY)
                scrollView.contentOffset.y -= offsetY
            }

            if offsetY < 0, headerViewHeightConstant < topViewHeightConstraintRange.upperBound, scrollView.contentOffset.y < 0 {
                innerTableViewDelegate?.didScroll(distance: offsetY)
                scrollView.contentOffset.y -= offsetY
            }
        }
        
        oldContentOffset = scrollView.contentOffset
        
    }
}
