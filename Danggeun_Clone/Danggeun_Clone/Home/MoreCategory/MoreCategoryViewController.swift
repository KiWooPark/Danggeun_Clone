//
//  MoreCategoryViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/01/17.
//

import UIKit
import Kingfisher

// MARK: [Class or Struct] ----------
class MoreCategoryViewController: UIViewController {
    
    // MARK: [@IBOutlet] ----------
    @IBOutlet var moreCategoryProductTableView: UITableView!
    @IBOutlet var indicatorView: UIActivityIndicatorView!
    
    // MARK: [Let Or Var] ----------
    lazy var refreshControl: UIRefreshControl = { [weak self] in
        let control = UIRefreshControl()
        return control
    }()
    
    var category: String?
    var productList = [ProductRegistrationModel]()
    var isPaging = false
    var userData: UserModel?

    // MARK: [Override] ----------
    override func viewDidLoad() {
        super.viewDidLoad()

        // 선택한 지역 내에서 검색

        setup()
        
        self.indicatorView.isHidden = false
        indicatorView.startAnimating()
        
        FirebaseManager.shared.fetchProducts(address: userData?.selectedAddress ?? "", category: category ?? "") { result in
            switch result {
            case .success(let products):
                
                self.productList = products
                
                DispatchQueue.main.async {
                    self.indicatorView.stopAnimating()
                    self.indicatorView.isHidden = true
                    self.moreCategoryProductTableView.reloadData()
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: [Function] ----------
    func setup() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        appearance.setBackIndicatorImage(UIImage(named: "backButton"), transitionMaskImage: UIImage(named: "backButton"))
        self.navigationItem.scrollEdgeAppearance = appearance
        self.navigationItem.standardAppearance = appearance
        
        self.navigationItem.title = category ?? ""
        
        let nibName = UINib(nibName: "ProductTableViewCell", bundle: nil)
        moreCategoryProductTableView.register(nibName, forCellReuseIdentifier: "productCell")
        
        moreCategoryProductTableView.prefetchDataSource = self
        
        moreCategoryProductTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        userData = UserModel.getUserData()
    }
    
    // MARK: [@objc Function] ----------
    @objc func refresh() {
        DispatchQueue.global().async {
            FirebaseManager.shared.resetProductsDownloadData(isCategory: true) {
                FirebaseManager.shared.fetchProducts(address: self.userData?.selectedAddress.components(separatedBy: " ").last ?? "", category: self.category ?? "") { result in
                    switch result {
                    case .success(let products):
                        self.productList = products
                        
                        DispatchQueue.main.async {
                            self.moreCategoryProductTableView.reloadData()
                            self.moreCategoryProductTableView.refreshControl?.endRefreshing()
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
extension MoreCategoryViewController: UITableViewDataSourcePrefetching {
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
extension MoreCategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as? ProductTableViewCell else { return UITableViewCell() }
        
        cell.titleLabel.text = productList[indexPath.row].title
        cell.addressLabel.text = productList[indexPath.row].address?.components(separatedBy: " ").last ?? ""
        cell.timeLabel.text = "\(productList[indexPath.row].update.convertTimestamp()) 전"
        cell.priceLabel.text = "\(productList[indexPath.row].price.insertComma)원"
        
        if productList[indexPath.row].status == ProductStatusType.completed.rawValue {
            cell.finishedLabel.isHidden = false
        } else if productList[indexPath.row].isReservation == true {
            cell.reservationLabel.isHidden = false
        }
        
        if productList[indexPath.row].likeCount == nil || productList[indexPath.row].likeCount == 0 {
            cell.chatAndLikeStackView.isHidden = true
        } else {
            cell.chatAndLikeStackView.isHidden = false
            cell.likeCountLabel.text = "\(productList[indexPath.row].likeCount ?? 0)"
        }
        
        if let image = productList[indexPath.row].ThumbnailImage {
            cell.productImageView.image = image
        } else {
            cell.productImageView.image = nil
            
            let targetUrl = productList[indexPath.row].imagesURL.first ?? ""
            
            FirebaseManager.shared.downloadThumbnailImage(url: targetUrl) { result in
                            
                switch result {
                case .success(let image):
                    self.productList[indexPath.row].ThumbnailImage = image
                    
                    let reloadTargetIndexPath = IndexPath(row: indexPath.row, section: 0)
                    
                    DispatchQueue.main.async {
                        self.moreCategoryProductTableView.reloadRows(at: [reloadTargetIndexPath], with: .automatic)
                    }
                    
                case .failure(let error):
                    print(error)
                }
            }
        }
        return cell
    }
}

// MARK: [TableView - Delegate] ----------
extension MoreCategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "ProductDetail", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "ProductDetailVC") as? ProductDetailViewController else { return }
        vc.productData = productList[indexPath.row]

        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: [ScrollView - Delegate] ----------
extension MoreCategoryViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let tableViewHeight = scrollView.frame.height
        
        if offsetY > (contentHeight - tableViewHeight - UIScreen.main.bounds.height * 0.3) {
            if isPaging == false && FirebaseManager.shared.productsHasNextPage {
                isPaging = true
                FirebaseManager.shared.pagingProducts(category: category ?? "") { result in
                    switch result {
                    case .success(let products):
                        self.productList.append(contentsOf: products)
                        self.isPaging = false
                        
                        DispatchQueue.main.async {
                            self.moreCategoryProductTableView.reloadData()
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
}
