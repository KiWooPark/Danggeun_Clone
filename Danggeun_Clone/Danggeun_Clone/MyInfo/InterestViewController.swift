//
//  InterestViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/09/06.
//

import UIKit
import FirebaseFirestore

class InterestViewController: UIViewController, InterestDelegate {
    
    var isButtonTouch = false
    func tapHeartButton(index: Int) {
        
        if isButtonTouch == true {
            return
        }
        
        isButtonTouch = true
        
        if productList[index].isLike ?? true {
            // 좋아요 카운트 내리고
            db.collection("게시글").document(productList[index].productId).getDocument { snapShot, error in
                if let error = error {
                    print("관심 상품 카운트 가져오기 실패", error)
                }

                guard let likesCount = snapShot?.data()?["likesCount"] as? Int else { return }

                self.db.collection("게시글").document(self.productList[index].productId).updateData(["likesCount": likesCount - 1]) { error in
                    if let error = error {
                        print("관심 상품 카운트 업데이트 실패", error)
                    }

                    // 게시글 - 관심 컬렉션에서 내 계정 정보 삭제
                    self.db.collection("게시글").document(self.productList[index].productId).collection("관심").document(UserModel.getUserData()?.phoneNumber ?? "").delete { error in
                        if let error = error {
                            print("관심 컬렉션에서 내 계정 정보 삭제 실패", error)
                        }

                        // 유저정보 - 관심 컬렉션에서 해당 게시물 삭제
                        self.db.collection("유저정보").document(UserModel.getUserData()?.phoneNumber ?? "").collection("관심").document(self.productList[index].productId).delete { error in
                            if let error = error {
                                print("관심 컬렉션에서 해당 게시물 삭제", error)
                            }

                            // 하트 버튼 빈 하트로 변경
                            DispatchQueue.main.async {
                                self.productList[index].isLike = false
                                self.isButtonTouch = false
                                self.interestTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                                
                            }
                        }
                    }
                }
            }
        } else {
            self.db.collection("게시글").document(self.productList[index].productId).collection("관심").document(UserModel.getUserData()?.phoneNumber ?? "").setData([:]) { error in
                if let error = error {
                    print("관심 유저 등록 실패", error)
                }
                
                self.db.collection("게시글").document(self.productList[index].productId).getDocument { snapShot, error in
                    if let error = error {
                        print("게시물 데이터 가져오기 실패", error)
                    }
                    
                    if let likesCount = snapShot?.data()?["likesCount"] as? Int {
                        self.db.collection("게시글").document(self.productList[index].productId).updateData(["likesCount": likesCount + 1]) { error in
                            if let error = error {
                                print("관심 카운트 업데이트 실패", error)
                            }
                           
                            DispatchQueue.main.async {
                                self.productList[index].isLike = true
                                self.isButtonTouch = false
                                self.interestTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                            }
                            
                            self.db.collection("유저정보").document(UserModel.getUserData()?.phoneNumber ?? "").collection("관심").document(self.productList[index].productId).setData([:]) { error in
                                if let error = error {
                                    print("유저정보에 관심상품 등록 실패", error)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    @IBOutlet var interestTableView: UITableView!
    
    var db = Firestore.firestore()
    
    var productList = [ProductRegistrationModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "관심목록"
        
        setup()
    }
    
    func setup() {
        db.collection("유저정보").document(UserModel.getUserData()?.phoneNumber ?? "").collection("관심").getDocuments { snapShot, error in
            if let error = error {
                print("관심 상품 가져오기 실패", error)
            }
            
            guard let documents = snapShot?.documents else { return }
            
            for document in documents {
                self.db.collection("게시글").document(document.documentID).getDocument { snapShot, error in
                    if let error = error {
                        print("게시글 가져오기 실패", error)
                    }
                    
                    guard let document = snapShot else { return }
                    
                    var productData = ProductRegistrationModel(singleData: document)
                    productData.isLike = true
                    
                    self.productList.append(productData)
                    
                    DispatchQueue.main.async {
                        self.interestTableView.reloadData()
                    }
                }
            }
        }
    }
}

extension InterestViewController: UITableViewDelegate {
    
}

extension InterestViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "interestProductCell", for: indexPath) as? InterestProductTableViewCell else { return UITableViewCell() }
        cell.productTitleLabel.text = productList[indexPath.row].title
        cell.addressLabel.text = productList[indexPath.row].address
        cell.priceLabel.text = "\(productList[indexPath.row].price)원"
        cell.chatCountLabel.text = "\(productList[indexPath.row].chattingCount ?? 0)"
        cell.likeCountLabel.text = "\(productList[indexPath.row].likeCount ?? 0)"
        
        cell.likeButton.tag = indexPath.row
        cell.delegate = self
        
        if productList[indexPath.row].isLike ?? true {
            cell.likeButton.setImage(UIImage(named: "like_selected"), for: .normal)
        } else {
            cell.likeButton.setImage(UIImage(named: "like_unselected"), for: .normal)
        }
        
        
        if productList[indexPath.row].status == ProductStatusType.finished.rawValue {
            cell.finishedLabel.isHidden = false
        } else if productList[indexPath.row].isReservation && productList[indexPath.row].status == ProductStatusType.onSale.rawValue {
            cell.reservationLabel.isHidden = false
        }
        
        FirebaseManager.shared.downloadImagesTest(url: productList[indexPath.row].imagesURL.first ?? "") { image in
            DispatchQueue.main.async {
                cell.productImageView.image = image == nil ? UIImage(named: "swift") : image?.resizeThumbnailTo()
            }
        }
        
        return cell
    }
    
    
}
