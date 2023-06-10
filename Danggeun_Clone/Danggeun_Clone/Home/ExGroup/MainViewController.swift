//
//  MainViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/12/29.
//

import UIKit
import FirebaseFirestore
import Kingfisher
import SnapKit
import BSImagePicker


//class MainViewController2: UIViewController {
//
//
//
//    let navigationTitleView = MyAddressView()
//
//
//    let db = Firestore.firestore()
//
//    var addressCount = 0
//
//    var selectedAddress: String?
//
//    var isFetching = false
//    var isPaging = false
//    var isRefresh = false
//    var isFirst = true
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // nib파일 연결
//
//
//        self.navigationController?.navigationBar.isHidden = false
//        plusButton.layer.cornerRadius = plusButton.frame.width * 0.5
//
//        productListTableView.refreshControl = UIRefreshControl()
//        productListTableView.refreshControl?.addTarget(self, action: #selector(refreshProducts), for: .valueChanged)
//
//        //configMyAddressButton()
//
//        FirebaseManager.shared.test { result in
//            print(result)
//        }
//
////        Task {
////            do {
////                let test = try await FirebaseManager.shared.fetchProducts(address: selectedAddress ?? "")
////
////
////            } catch {
////                print("123")
////            }
////        }
//
////        Task {
////            do {
////                let products = try await FirebaseManager.shared.fetchProducts(address: selectedAddress ?? "")
////
////                productList = products
////
////                print(productList.count)
////
////                DispatchQueue.main.async {
////                    self.activityIndicatorView.isHidden = true
////                    self.productListTableView.reloadData()
////                }
////            } catch {
////
////            }
////        }
//
//
//
//        //fetchAddressProducts()
//
//        NotificationCenter.default.addObserver(self, selector: #selector(refreshProducts), name: .reloadProductListTableView, object: nil)
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        // 디렉토리 확인
//        //print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true))
//        print("====================================================")
//    }
//
//
//    func fetchAddressProducts() {
//
//        if isFetching == false {
//            activityIndicatorView.isHidden = false
//            activityIndicatorView.startAnimating()
//            isFetching = true
//
//            Task {
//                do {
//                    let products = try await FirebaseManager.shared.reloadProducts(address: selectedAddress ?? "")
//                    productList = products
//
//                    activityIndicatorView.stopAnimating()
//                    activityIndicatorView.isHidden = true
//                    isFetching = false
//
//                    DispatchQueue.main.async {
//                        self.productListTableView.reloadData()
//                    }
//                } catch let e {
//                    print("fetchAddressProducts", e.localizedDescription)
//                }
//            }
//        }
//    }
//
//    func leftBarButtonImageRotation() {
//        UIView.animate(withDuration: 0.5, delay: 0) {
//            self.navigationTitleView.addressButton.imageView?.transform = .identity
//        }
//    }
//
//    @objc func refreshProducts() {
//        if isRefresh == false {
//            isRefresh = true
//
//            Task {
//                do {
//                    let products = try await FirebaseManager.shared.reloadProducts(address: selectedAddress ?? "")
//                    productList.removeAll()
//                    productList = products
//
//                    productListTableView.refreshControl?.endRefreshing()
//                    isRefresh = false
//
//                    DispatchQueue.main.async {
//                        self.productListTableView.reloadData()
//                    }
//                } catch let e {
//                    print("refreshProducts", e.localizedDescription)
//                }
//            }
//        }
//    }
//
//
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let nextVC = segue.destination as? SearchProductViewController {
//            nextVC.addressName = selectedAddress ?? ""
//        }
//    }
//
//    @IBAction func tapPlusButton(_ sender: Any) {
//        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "popupAddProductView") as? AddProductPopupViewController else { return }
//        let tabBarHeight = self.tabBarController?.tabBar.frame.height
//        vc.tabBarHeight = tabBarHeight
//        vc.modalPresentationStyle = .overFullScreen
//        self.present(vc, animated: false)
//    }
//
//    func configMyAddressButton() {
//
//        let userData = UserModel.getUserData()
//
//        selectedAddress = userData?.selectedAddress ?? ""
//        addressCount = userData?.address2 != "" ? 2 : 1
//
//        navigationTitleView.addressButton.addTarget(self, action: #selector(tapMyAddressButton), for: .touchUpInside)
//        navigationTitleView.addressButton.setTitle(userData?.selectedAddress.components(separatedBy: " ").last ?? "", for: .normal)
//        navigationTitleView.addressButton.layoutIfNeeded()
//
//        self.navigationItem.titleView = navigationTitleView
//    }
//
//
//    @objc func tapMyAddressButton() {
//
//        if addressCount == 1 {
//
//            guard let nvc = self.storyboard?.instantiateViewController(withIdentifier: "settingNavigationVC") as? UINavigationController else { return }
//
//            nvc.modalPresentationStyle = .fullScreen
//            self.present(nvc, animated: true)
//
//        } else {
//
//
//            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "myAddressPopupVC") as? MyAddressPopupViewController else { return }
//            vc.delegate = self
//            vc.navigationHeight = self.navigationController?.navigationBar.frame.height ?? 0.0
//
//            // 바버튼 아이템 프레임 사이즈
//            if let barButtonItem = self.navigationItem.leftBarButtonItem {
//                if let leftButton = barButtonItem.value(forKey: "view") as? UIView {
//                    vc.addressButtonCenter = leftButton.center
//                }
//            }
//
//
//            UIView.animate(withDuration: 0.5, delay: 0) {
//                self.navigationTitleView.addressButton.imageView?.transform = CGAffineTransform(rotationAngle: 180 * .pi / 180)
//            }
//
//            vc.modalPresentationStyle = .overFullScreen
//            self.present(vc, animated: false)
//        }
//    }
//}
//
//
//extension MainViewController: UITableViewDataSource {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 2
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 0 {
//            return productList.count
//        } else if section == 1 && isPaging {
//            return 1
//        } else {
//            return 0
//        }
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        if indexPath.section == 0 {
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as? ProductTableViewCell else { return UITableViewCell() }
//
//            cell.titleLabel.text = productList[indexPath.row].title
//            cell.addressLabel.text = productList[indexPath.row].regionName
//            cell.timeLabel.text = "\(productList[indexPath.row].update.convertTimestamp()) 전"
//            cell.priceLabel.text = "\(productList[indexPath.row].price)원"
//
////            if productList[indexPath.row].isReservation {
////                cell.reservationLabel.isHidden = false
////            }
////
////            if productList[indexPath.row].isFinished {
////                cell.finishedLabel.isHidden = false
////            }
////
////            if productList[indexPath.row].likesCount == 0 && productList[indexPath.row].chattingCount == 0 {
////                cell.chatAndLikeStackView.isHidden = true
////            } else if productList[indexPath.row].likesCount == 0 || productList[indexPath.row].chattingCount != 0 {
////                cell.likeImageView.isHidden = true
////                cell.likeCountLabel.isHidden = true
////                cell.chatCountLabel.text = "\(productList[indexPath.row].chattingCount ?? 0)"
////            } else if productList[indexPath.row].likesCount != 0 || productList[indexPath.row].chattingCount == 0 {
////                cell.chatImageView.isHidden = true
////                cell.chatCountLabel.isHidden = true
////                cell.likeCountLabel.text = "\(productList[indexPath.row].likesCount ?? 0)"
////            }
//
//
//            if let imageView = cell.viewWithTag(100) as? UIImageView {
//                if let image = productList[indexPath.row].ThumbnailImage {
//                    print("이미지 있음", indexPath.row)
//                    imageView.image = image
//                } else {
//                    print("이미지 없음", indexPath.row)
//                    imageView.image = nil
//                    let isThumbnail = productList[indexPath.row].ThumbnailImage == nil ? true : false
//
//                    FirebaseManager.shared.downloadProductsThumbnailImage(url: productList[indexPath.row].photos.first ?? "", isThumbnail: isThumbnail) { image in
//
//                        self.productList[indexPath.row].ThumbnailImage = image
//
//                        let reloadTargetIndexPath = IndexPath(row: indexPath.row, section: 0)
//
//                        DispatchQueue.main.async {
//                            if self.productListTableView.indexPathsForVisibleRows?.contains(reloadTargetIndexPath) == .some(true) {
//                                self.productListTableView.reloadRows(at: [reloadTargetIndexPath], with: .automatic)
//                            }
//                        }
//                    }
//                }
//            }
//
////            FirebaseManager.shared.downloadImagesTest(url: productList[indexPath.row].photos.first ?? "") { image in
////                DispatchQueue.main.async {
////                    cell.productImageView.image = image == nil ? UIImage(named: "swift") : image?.resizeThumbnailTo()
////                }
////            }
//            return cell
//        } else if indexPath.section == 1 {
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: "indicatorCell") as? ProductIndicatorTableViewCell else { return UITableViewCell() }
//            cell.indicatorView.startAnimating()
//            return cell
//        }
//        return UITableViewCell()
//    }
//}
//
//extension MainViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let vc = storyboard?.instantiateViewController(withIdentifier: "detail") as? ProductDetaileViewController else { return }
//        vc.productData = productList[indexPath.row]
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
//}
//
//extension MainViewController: UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let offsetY = scrollView.contentOffset.y
//        let contentHeight = productListTableView.contentSize.height
//        let height = productListTableView.frame.height
//
//        if offsetY > (contentHeight - height) && (contentHeight - height) > 0 {
//            if isPaging == false {
//                isPaging = true
//                DispatchQueue.main.async {
//                    self.productListTableView.reloadSections(IndexSet(integer: 1), with: .none)
//                }
//
//                Task {
//                    do {
//                        let result = try await FirebaseManager.shared.pagingProducts(address: selectedAddress ?? "", products: productList)
//                        productList.append(contentsOf: result.0)
//                        self.isPaging = result.1
//
//                        DispatchQueue.main.async {
//                            self.productListTableView.reloadData()
//                        }
//                    } catch let e {
//                        print("scrollViewDidScroll 에러", e.localizedDescription)
//                    }
//                }
//            }
//        }
//    }
//}
//
//
//extension MainViewController: MyAddressPopupViewControllerDelegate {
//    func updateAddressButton() {
//        configMyAddressButton()
//    }
//
//    func fetchProducts() {
//        fetchAddressProducts()
//    }
//}

