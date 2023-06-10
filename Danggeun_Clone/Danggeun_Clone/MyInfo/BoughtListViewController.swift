//
//  BoughtListViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/08/02.
//

import UIKit
import FirebaseFirestore

// 구매내역 뷰컨트롤러
class BoughtListViewController: UIViewController, BoughtCellDelegate {
    func tapSendButton(index: Int, title: String) {
        if title == "보낸 후기 보기" {
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "sendReviewVC") as? SendReviewViewController else { return }
            vc.vcType = "buy"
            vc.productData = productList[index]
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            if !(productList[index].isBuyerReview ?? false) {
                FirebaseManager.shared.getUserData(userPhoneNumber: productList[index].phoneNumber) { user in
                    let seller = ReservationChattingUserModel(phoneNumber: user?.phoneNumber ?? "", nickname: user?.nickname ?? "", profileImageUrl: nil, address: nil, lastUpdate: nil)

                    guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "selectReviewVC") as? ReviewViewController else { return }

                    // 게시글 제목
                    vc.productId = self.productList[index].productId
                    vc.productTitle = self.productList[index].title
                    vc.otherUser = seller
                    vc.vcType = "buyer"
                    self.navigationController?.pushViewController(vc, animated:true)
                }
            } else {
                guard let vc = storyboard?.instantiateViewController(withIdentifier: "selectReviewVC") as? ReviewViewController else { return }
                self.navigationController?.pushViewController(vc, animated:true)
            }
        }
    }

    func tapBoughtAddButton(index: Int) {
        print(index)
    }


    var productList = [ProductRegistrationModel]()

    let db = Firestore.firestore()

    @IBOutlet var boughtListTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let nibName = UINib(nibName: "BoughtListTableViewCell", bundle: nil)
        boughtListTableView.register(nibName, forCellReuseIdentifier: "boughtCell")

        fetchProducts()

    }

    func fetchProducts() {
        db.collection("유저정보").document(UserModel.getUserData()?.phoneNumber ?? "").getDocument { snapShot, error in
            if let error = error {
                print(error)
            }

            guard let finishProducts = snapShot?.data()?["finishProducts"] as? [String] else { return }

            self.productList.removeAll()

            for product in finishProducts {
                self.db.collection("게시글").document(product).getDocument { snapShot, error in
                    if let error = error {
                        print(error)
                    }
                    guard let product = snapShot else { return }
                    let productModel = ProductRegistrationModel(singleData: product)

                    self.productList.append(productModel)
                    self.boughtListTableView.reloadData()
                }
            }
        }
    }
}

extension BoughtListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "boughtCell", for: indexPath) as? BoughtListTableViewCell else { return UITableViewCell() }
        cell.titleLabel.text = productList[indexPath.row].title
        cell.addressLabel.text = productList[indexPath.row].address
        cell.timeLabel.text = "\(productList[indexPath.row].update.convertTimestamp()) 전"
        cell.priceLabel.text = "\(productList[indexPath.row].price)원"

        cell.boughtDelegate = self

        FirebaseManager.shared.downloadImagesTest(url: productList[indexPath.section].imagesURL[0]) { image in
            DispatchQueue.main.async {
                cell.productImageView.image = image?.resizeThumbnailTo()
            }
        }

        if productList[indexPath.row].isBuyerReview ?? false {
            cell.sendReviewButton.setTitle("보낸 후기 보기", for: .normal)
            cell.sendReviewButton.tag = indexPath.row
        } else {
            cell.sendReviewButton.tag = indexPath.row
        }

        return cell
    }
}

