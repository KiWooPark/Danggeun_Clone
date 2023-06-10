////
////  OtherProductsListViewController.swift
////  Danggeun_Clone
////
////  Created by PKW on 2022/06/17.
////
//
//import UIKit
//import SnapKit
//import FirebaseFirestore
//
//class OtherProductsListViewController: UIViewController {
//
//    @IBOutlet var tableViewsInScrollView: UIScrollView!
//    @IBOutlet var underlineView: UIView!
//
//    @IBOutlet var totalTableView: UITableView!
//    @IBOutlet var ongoingTableView: UITableView!
//    @IBOutlet var finishedTableView: UITableView!
//
//    @IBOutlet var totalButton: UIButton!
//    @IBOutlet var ongoingButton: UIButton!
//    @IBOutlet var finishedButton: UIButton!
//
//    let db = Firestore.firestore()
//
//    var phoneNumber: String?
//
//    var totalProduts = [ProductRegistrationModel]()
//    var ongoingProducts = [ProductRegistrationModel]()
//    var finishedProducts = [ProductRegistrationModel]()
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.title = "판매 상품 보기"
//
//        fetchDB()
//    }
//
//    func fetchDB() {
//        db.collection("게시글").whereField("phoneNumber", isEqualTo: phoneNumber).getDocuments { snapShot, error in
//            if let error = error {
//                print("게시글 가져오기 실패 = \(error) // OtherProductsListViewController")
//            }
//
//            guard let documents = snapShot?.documents else { return }
//
//            for productData in documents {
//                let product = ProductRegistrationModel(data: productData)
//                self.totalProduts.append(product)
//
//                // 판매 완료 상품 체크
//                if productData.data()["finished"] as? Bool ?? false == false {
//                    self.ongoingProducts.append(product)
//                } else {
//                    self.finishedProducts.append(product)
//                }
//            }
//
//            self.totalTableView.reloadData()
//            self.ongoingTableView.reloadData()
//            self.finishedTableView.reloadData()
//        }
//    }
//
//    @IBAction func tapTotalButton(_ sender: Any) {
//        UIView.animate(withDuration: 0.5) {
//            self.underlineView.center.x = self.totalButton.center.x
//            self.tableViewsInScrollView.contentOffset.x = self.totalTableView.frame.origin.x
//        }
//    }
//
//    @IBAction func tapOngoingButton(_ sender: Any) {
//        UIView.animate(withDuration: 0.5) {
//            self.underlineView.center.x = self.ongoingButton.center.x
//            self.tableViewsInScrollView.contentOffset.x = self.ongoingTableView.frame.origin.x
//        }
//    }
//
//    @IBAction func tapFinishedButton(_ sender: Any) {
//        UIView.animate(withDuration: 0.5) {
//            self.underlineView.center.x = self.finishedButton.center.x
//            self.tableViewsInScrollView.contentOffset.x = self.finishedTableView.frame.origin.x
//        }
//    }
//}
//
//extension OtherProductsListViewController: UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView.restorationIdentifier == "mainScrollView" {
//            underlineView.frame.origin.x = scrollView.contentOffset.x / 3
//            print(scrollView.contentOffset)
//        }
//    }
//}
//
//extension OtherProductsListViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        guard let vc = storyboard?.instantiateViewController(withIdentifier: "detail") as? ProductDetaileViewController else { return }
//
//        if tableView.tag == 1 {
//            //vc.product = totalProduts[indexPath.row]
//        } else if tableView.tag == 2 {
//            //vc.product = ongoingProducts[indexPath.row]
//        } else {
//            //vc.product = finishedProducts[indexPath.row]
//        }
//
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
//}
//
//extension OtherProductsListViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if tableView.tag == 1 {
//            return totalProduts.count
//        } else if tableView.tag == 2 {
//            return ongoingProducts.count
//        } else {
//            return finishedProducts.count
//        }
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as? ProductListTableViewCell else { return UITableViewCell() }
//
//        if tableView.tag == 1 {
//            cell.titleLabel.text = totalProduts[indexPath.row].title
//            cell.addressLabel.text = totalProduts[indexPath.row].address
//            cell.timeLabel.text = "\(totalProduts[indexPath.row].update.convertTimestamp()) 전"
//            cell.priceLabel.text = totalProduts[indexPath.row].price
//            cell.productImageView.kf.setImage(with: URL(string: totalProduts[indexPath.row].photos.first ?? ""),placeholder: UIImage(named: "swift"))
//            return cell
//        } else if tableView.tag == 2 {
//            cell.titleLabel.text = ongoingProducts[indexPath.row].title
//            cell.addressLabel.text = ongoingProducts[indexPath.row].address
//            cell.timeLabel.text = "\(ongoingProducts[indexPath.row].update.convertTimestamp()) 전"
//            cell.priceLabel.text = ongoingProducts[indexPath.row].price
//            cell.productImageView.kf.setImage(with: URL(string: ongoingProducts[indexPath.row].photos.first ?? ""),placeholder: UIImage(named: "swift"))
//            return cell
//        } else {
//            cell.titleLabel.text = finishedProducts[indexPath.row].title
//            cell.addressLabel.text = finishedProducts[indexPath.row].address
//            cell.timeLabel.text = "\(finishedProducts[indexPath.row].update.convertTimestamp()) 전"
//            cell.priceLabel.text = finishedProducts[indexPath.row].price
//            cell.productImageView.kf.setImage(with: URL(string: finishedProducts[indexPath.row].photos.first ?? ""),placeholder: UIImage(named: "swift"))
//            return cell
//        }
//    }
//}
