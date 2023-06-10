//
//  FirstViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/01/19.
//

import UIKit
import FirebaseFirestore
import Kingfisher

// MARK: [Protocol] ----------
protocol InnerTableViewScrollDelegate: AnyObject {
    var headerHeight: CGFloat { get }
    func didScroll(distance: CGFloat)
}

// MARK: [Class or Struct] ----------
class FirstViewController: UIViewController {

    // MARK: [@IBOutlet] ----------
    @IBOutlet var firstTableview: UITableView!
    
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
        firstTableview.register(nibName, forCellReuseIdentifier: "productCell")
        
        firstTableview.prefetchDataSource = self

        firstTableview.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        configProductsData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTradingProduct), name: .updateTradingProduct, object: nil)
    }
    
    // MARK: [Function] ----------
    func configProductsData() {
        showProductStatus = UserModel.getUserData()?.phoneNumber ?? ""  == userPhoneNumber ? .trading : .all
        
        FirebaseManager.shared.fetchAllOrTradingOrCompletedOtherProducts(phoneNumber: userPhoneNumber, status: showProductStatus) { result in
            switch result {
            case .success(let products):
                self.products.removeAll()
                self.products = products
                
                DispatchQueue.main.async {
                    self.firstTableview.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: [@objc Function] ----------
    @objc func updateTradingProduct() {
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
        
        let hidden = UIAlertAction(title: "숨기기", style: .default) { _ in

            FirebaseManager.shared.updateHiddenProduct(id: self.products[button.tag].productId, address: self.products[button.tag].address ?? "", isHidden: true, status: self.products[button.tag].status) {
                
                self.configProductsData()
                NotificationCenter.default.post(name: .updateHiddenProduct, object: nil)
                NotificationCenter.default.post(name: .updateProductsCount, object: nil)
                NotificationCenter.default.post(name: .reloadMainViewProducts, object: nil)
            }
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
        alert.addAction(hidden)
        alert.addAction(delete)
        alert.addAction(close)
        
        self.present(alert, animated: true)
    }
    
    @objc func refresh() {
        DispatchQueue.global().async {
            FirebaseManager.shared.resetOtherProductsDownloadData(status: self.showProductStatus) {
                FirebaseManager.shared.fetchAllOrTradingOrCompletedOtherProducts(phoneNumber: self.userPhoneNumber, status: self.showProductStatus) { result in
                    switch result {
                    case .success(let products):
                        self.products.removeAll()
                        self.products = products
                        
                        NotificationCenter.default.post(name: .updateProductsCount, object: nil)
                    
                        DispatchQueue.main.async {
                            self.firstTableview.reloadData()
                            self.firstTableview.refreshControl?.endRefreshing()
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
    
    @objc func tapReservationButton(button: UIButton) {
        FirebaseManager.shared.updateReservationProduct(id: products[button.tag].productId, address: products[button.tag].address ?? "", isReservation: false) {
            guard let cell = self.firstTableview.cellForRow(at: IndexPath(row: button.tag, section: 0)) as? TradingProductTableViewCell else { return }
            
            cell.reservationLabel.isHidden = false
            cell.tradingButton.isHidden = false
            cell.reservationButton.isHidden = true
            
            NotificationCenter.default.post(name: .reloadMainViewProducts, object: nil)
        }
    }
    
    @objc func tapCompletedButton(button: UIButton) {

        FirebaseManager.shared.updateCompletedProduct(id: products[button.tag].productId, address: products[button.tag].address ?? "", isCompleted: false) {
            self.configProductsData()
            NotificationCenter.default.post(name: .updateProductsCount, object: nil)
            NotificationCenter.default.post(name: .updateCompletedProduct, object: nil)
            NotificationCenter.default.post(name: .reloadMainViewProducts, object: nil)
        }
    }
    
    @objc func tapTradingButton(button: UIButton) {
        FirebaseManager.shared.updateReservationProduct(id: products[button.tag].productId, address: products[button.tag].address ?? "", isReservation: true) {
            guard let cell = self.firstTableview.cellForRow(at: IndexPath(row: button.tag, section: 0)) as? TradingProductTableViewCell else { return }
            
            cell.reservationLabel.isHidden = true
            cell.tradingButton.isHidden = true
            cell.reservationButton.isHidden = false
            
            NotificationCenter.default.post(name: .reloadMainViewProducts, object: nil)
        }
    }
}

// MARK: [TableView - DataSourcePrefetching] ----------
extension FirstViewController: UITableViewDataSourcePrefetching {
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
            if let targetUrl = URL(string: products[indexPath.row].imagesURL.first ?? "") {
                KingfisherManager.shared.downloader.cancel(url: targetUrl)
            }
        }
    }
}

// MARK: [TableView - DataSource] ----------
extension FirstViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if showProductStatus == .all {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as? ProductTableViewCell else { return UITableViewCell() }

            let target = products[indexPath.row]
            
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
            
            if let image = target.ThumbnailImage {
                cell.productImageView.image = image
            } else {
                cell.productImageView.image = nil
                
                let targetUrl = target.imagesURL.first ?? ""
                
                FirebaseManager.shared.downloadThumbnailImage(url: targetUrl) { result in
                                
                    switch result {
                    case .success(let image):
                        self.products[indexPath.row].ThumbnailImage = image
                        
                        let reloadTargetIndexPath = IndexPath(row: indexPath.row, section: 0)
                        
                        DispatchQueue.main.async {
                            self.firstTableview.reloadRows(at: [reloadTargetIndexPath], with: .automatic)
                        }
                        
                    case .failure(let error):
                        print(error)
                    }
                }
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "tradingCell") as? TradingProductTableViewCell else { return UITableViewCell() }
            
            cell.titleLabel.text = products[indexPath.row].title
            cell.addressLabel.text = products[indexPath.row].address?.components(separatedBy: " ").last ?? ""
            cell.timeLabel.text =  "\(products[indexPath.row].update.convertTimestamp()) 전"
            cell.priceLabel.text = "\(products[indexPath.row].price.insertComma)원"
            
            cell.reservationLabel.isHidden = products[indexPath.row].isReservation ? false : true
            
            if products[indexPath.row].likeCount == nil || products[indexPath.row].likeCount == 0 {
                cell.likeCountStackView.isHidden = true
            } else {
                cell.likeCountStackView.isHidden = false
                cell.likeCountLabel.text = "\(products[indexPath.row].likeCount ?? 0)"
            }
        
            cell.tradingButton.tag = indexPath.row
            cell.tradingButton.addTarget(self, action: #selector(tapTradingButton(button:)), for: .touchUpInside)
            cell.completedButton.tag = indexPath.row
            cell.completedButton.addTarget(self, action: #selector(tapCompletedButton(button:)), for: .touchUpInside)
            cell.reservationButton.tag = indexPath.row
            cell.reservationButton.addTarget(self, action: #selector(tapReservationButton(button:)), for: .touchUpInside)
            cell.moreMenuButton.tag = indexPath.row
            cell.moreMenuButton.addTarget(self, action: #selector(tapMoreMenuButton), for: .touchUpInside)
            
            if !products[indexPath.row].isReservation {
                cell.tradingButton.isHidden = true
            } else {
                cell.reservationButton.isHidden = true
                cell.reservationLabel.isHidden = false
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
                            self.firstTableview.reloadRows(at: [reloadTargetIndexPath], with: .automatic)
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
extension FirstViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "ProductDetail", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "ProductDetailVC") as? ProductDetailViewController else { return }
        vc.productData = products[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: [ScrollView - Delegate] ----------
extension FirstViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let y = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let tableViewHeight = scrollView.frame.height
        
        let hasNextPage = showProductStatus == .all ? FirebaseManager.shared.allOtherProductHasNextPage : FirebaseManager.shared.tradingOtherProductHasNextPage
        
        if y > (contentHeight - tableViewHeight - UIScreen.main.bounds.height * 0.3) {
            if isPaging == false && hasNextPage {
                
                self.isPaging = true

                let status = showProductStatus == .all ? ProductStatusType.all : ProductStatusType.trading
                
                FirebaseManager.shared.pagingAllOrTradingOrCompletedOtherProducts(phoneNumber: userPhoneNumber, status: status) { result in
                    switch result {
                    case .success(let products):
                        self.products.append(contentsOf: products)
                        self.isPaging = false

                        DispatchQueue.main.async {
                            self.firstTableview.reloadData()
                        }

                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }

        // 현재 offset과 oldOffset 뺀 값
        let offsetY = scrollView.contentOffset.y - oldContentOffset.y
        
        // 스티키헤더뷰 높이
        let stikcyHeaderViewHeightConstant = innerTableViewDelegate?.headerHeight
        
        if let stikcyHeaderViewHeightConstant = stikcyHeaderViewHeightConstant {
            
            // offsetY가 0 보다 클때 (위로 스크롤)
            // offsetY = offset과 oldOffset 뺀값
            // topViewHeightConstraintRange.lowerBound = 0
            // scrollView.contentOffset.y = 현재 offsetY값
            if offsetY > 0, stikcyHeaderViewHeightConstant > topViewHeightConstraintRange.lowerBound, scrollView.contentOffset.y > 0 {
                innerTableViewDelegate?.didScroll(distance: offsetY)
                scrollView.contentOffset.y -= offsetY
            }

            // offsetY가 0 보다 클때 (아래로 스크롤)
            if offsetY < 0, stikcyHeaderViewHeightConstant < topViewHeightConstraintRange.upperBound, scrollView.contentOffset.y < 0 {
                innerTableViewDelegate?.didScroll(distance: offsetY)
                scrollView.contentOffset.y -= offsetY
            }
        }
        oldContentOffset = scrollView.contentOffset
    }
}

