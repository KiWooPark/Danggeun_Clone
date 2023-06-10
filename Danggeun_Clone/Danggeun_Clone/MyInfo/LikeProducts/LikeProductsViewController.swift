//
//  LikeProductsViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/02/13.
//

import UIKit
import Kingfisher

// MARK: [Class or Struct] ----------
class LikeProductsViewController: UIViewController {
    
    // MARK: [@IBOutlet] ----------
    @IBOutlet var likeProductsTableView: UITableView!
    
    // MARK: [Let Or Var] ----------
    lazy var refreshControl: UIRefreshControl = { [weak self] in
        let control = UIRefreshControl()
        return control
    }()
    
    var productList = [ProductRegistrationModel]()
    
    var isPaging = false
    
    // MARK: [Override] ----------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        likeProductsTableView.prefetchDataSource = self
        
        likeProductsTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        FirebaseManager.shared.fetchLikeProducts { result in
            switch result {
            case .success(let products):
                products.forEach { product in
                    if var product = product {
                        product.isLike = true
                        self.productList.append(product)
                    }
                }
                
                DispatchQueue.main.async {
                    self.likeProductsTableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
        
        let appearance = UINavigationBarAppearance()
        appearance.setBackIndicatorImage(UIImage(named: "backButton"), transitionMaskImage: UIImage(named: "backButton"))
        appearance.backgroundColor = .white
        
        self.navigationItem.standardAppearance = appearance
        self.navigationItem.scrollEdgeAppearance = appearance
    }
    
    // MARK: [@objc Function] ----------
    @objc func tapLikeButton(button: UIButton) {
        FirebaseManager.shared.updateLike(id: productList[button.tag].productId, address: productList[button.tag].address ?? "", isLike: productList[button.tag].isLike ?? false) { _, count  in
            
            self.productList[button.tag].isLike?.toggle()
            
            guard let cell = self.likeProductsTableView.cellForRow(at: IndexPath(row: button.tag, section: 0)) as? LikeProductTableViewCell else { return }
            
            
            
            if self.productList[button.tag].isLike ?? false {
                button.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                button.tintColor = .orange
                
                if count > 0 {
                    cell.likeCountStackView.isHidden = false
                    cell.likeCountLabel.text = "\(count)"
                }
            
            } else {
                button.setImage(UIImage(systemName: "heart"), for: .normal)
                button.tintColor = .darkGray
                    
                if count == 0 {
                    cell.likeCountStackView.isHidden = true
                } else {
                    cell.likeCountLabel.text = "\(count)"
                }
              
            }
        }
    }
    
    @objc func refresh() {
        DispatchQueue.global().async {
            
            FirebaseManager.shared.resetLikeProductsDownloadData {
                FirebaseManager.shared.fetchLikeProducts { result in
                    switch result {
                    case .success(let products):
                        self.productList.removeAll()
                        products.forEach { product in
                            
                            if var product = product {
                                product.isLike = true
                                self.productList.append(product)
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.likeProductsTableView.reloadData()
                            self.likeProductsTableView.refreshControl?.endRefreshing()
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
extension LikeProductsViewController: UITableViewDataSourcePrefetching {
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
extension LikeProductsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "likeProductCell", for: indexPath) as? LikeProductTableViewCell else { return UITableViewCell() }
        
        let target = productList[indexPath.row]

        cell.titleLabel.text = target.title
        cell.addressLabel.text = target.address?.components(separatedBy: " ").last ?? ""
        cell.timeLabel.text = target.update.convertTimestamp()
        cell.priceLabel.text = "\(target.price.insertComma)원"
        cell.likeButton.tag = indexPath.row
        cell.likeButton.addTarget(self, action: #selector(tapLikeButton(button:)), for: .touchUpInside)
        
        if target.status == ProductStatusType.completed.rawValue {
            cell.finishedLabel.isHidden = false
        } else if target.isReservation == true {
            cell.reservationLabel.isHidden = false
        }
        
        if target.likeCount == nil || target.likeCount == 0 {
            cell.likeCountStackView.isHidden = true
        } else {
            cell.likeCountStackView.isHidden = false
            cell.likeCountLabel.text = "\(target.likeCount ?? 0)"
            cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            cell.likeButton.tintColor = .orange
        }
        
        if let image = target.ThumbnailImage {
            cell.thumbnailImageView.image = image
        } else {
            cell.thumbnailImageView.image = nil
            
            let targetUrl = target.imagesURL.first ?? ""
            
            FirebaseManager.shared.downloadThumbnailImage(url: targetUrl) { result in
                            
                switch result {
                case .success(let image):
                    self.productList[indexPath.row].ThumbnailImage = image
                    
                    let reloadTargetIndexPath = IndexPath(row: indexPath.row, section: 0)
                    
                    DispatchQueue.main.async {
                        self.likeProductsTableView.reloadRows(at: [reloadTargetIndexPath], with: .automatic)
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
extension LikeProductsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "ProductDetail", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "ProductDetailVC") as? ProductDetailViewController else { return }
        vc.productData = productList[indexPath.row]
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: [ScrollView - Delegate] ----------
extension LikeProductsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let tableViewHeight = scrollView.frame.height
        
        if offsetY > (contentHeight - tableViewHeight - UIScreen.main.bounds.height * 0.3) {
        
            if isPaging == false && FirebaseManager.shared.likeProductsHaseNextPage {
                isPaging = true
                FirebaseManager.shared.pagingLikeProducts { result in
                    switch result {
                    case .success(let products):
                        products.forEach { product in
                            if var product = product {
                                product.isLike = true
                                self.productList.append(product)
                            }
                        }
                        
                        self.isPaging = false
                        
                        DispatchQueue.main.async {
                            self.likeProductsTableView.reloadData()
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
}

extension LikeProductsViewController: ProductDetailViewControllerDelegate {
    func fetchProductAfterDelete() {
        refresh()
    }
}
