//
//  MyProductsListViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/07/29.
//

import UIKit
import FirebaseFirestore

class MyProductsListViewController: UIViewController {
    
    @IBOutlet var myProductsListScrollView: UIScrollView!
    
    @IBOutlet var onSaleTableView: UITableView!
    @IBOutlet var finishedTableView: UITableView!
    @IBOutlet var hideTableView: UITableView!
    
    @IBOutlet var onSaleButton: UIButton!
    @IBOutlet var finishedButton: UIButton!
    @IBOutlet var hideButton: UIButton!
    
    @IBOutlet var underLineView: UIView!
    @IBOutlet var underLineViewWidth: NSLayoutConstraint!
    
    var onSaleProducts = [ProductRegistrationModel]()
    var finishedProducts = [ProductRegistrationModel]()
    var hideProducts = [ProductRegistrationModel]()
    
    let db = Firestore.firestore()
    
    var userPhoneNumber = UserModel.getUserData()?.phoneNumber ?? ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        underLineViewWidth.constant = onSaleButton.frame.width
        
        FirebaseManager.shared.getProductsId(phoneNumber: userPhoneNumber) { onSaleList, finishedList, hideList in
            self.onSaleProducts = onSaleList
            self.finishedProducts = finishedList
            self.hideProducts = hideList
            
            DispatchQueue.main.async {
                self.onSaleTableView.reloadData()
                self.finishedTableView.reloadData()
                self.hideTableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FirebaseManager.shared.getProductsId(phoneNumber: userPhoneNumber) { onSaleList, finishedList, hideList in
            self.onSaleProducts = onSaleList
            self.finishedProducts = finishedList
            self.hideProducts = hideList
            
            DispatchQueue.main.async {
                self.onSaleTableView.reloadData()
                self.finishedTableView.reloadData()
                self.hideTableView.reloadData()
            }
        }
    }
    
    @IBAction func tapOnSaleButton(_ sender: Any) {
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
            
            self.underLineView.center.x = self.onSaleButton.center.x
            self.myProductsListScrollView.contentOffset.x = self.onSaleTableView.frame.origin.x
        }
    }
    
    @IBAction func tapBoughtButton(_ sender: Any) {
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
            
            self.underLineView.center.x = self.finishedButton.center.x
            self.myProductsListScrollView.contentOffset.x = self.finishedTableView.frame.origin.x
            
        }
    }
    
    @IBAction func tapHideButton(_ sender: Any) {
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
            
            self.underLineView.center.x = self.hideButton.center.x
            self.myProductsListScrollView.contentOffset.x = self.hideTableView.frame.origin.x
            
        }
    }
}


extension MyProductsListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        let target = tableView.tag
        
        switch target {
        case 0:
            return onSaleProducts.count
        case 1:
            return finishedProducts.count
        case 2:
            return hideProducts.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let target = tableView.tag
        
        switch target {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch tableView.tag {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "onSaleCell") as? OnSaleTableViewCell else { return UITableViewCell() }
            
            FirebaseManager.shared.downloadImagesTest(url: onSaleProducts[indexPath.section].imagesURL[0]) { image in
                DispatchQueue.main.async {
                    cell.productImageView.image = image?.resizeThumbnailTo()
                }
            }
            cell.reservationButton.tag = indexPath.section
            cell.finishTransationButton.tag = indexPath.section
            cell.addButton.tag = indexPath.section
            cell.delegate = self
            
            if onSaleProducts[indexPath.section].isReservation {
                cell.reservationButton.setTitle("판매중", for: .normal)
            } else {
                cell.reservationButton.setTitle("예약중", for: .normal)
            }
            
            cell.reservationLabel.isHidden = onSaleProducts[indexPath.section].isReservation == true ? false : true
            
            cell.titleLabel.text = onSaleProducts[indexPath.section].title
            cell.addressLabel.text = onSaleProducts[indexPath.section].address
            cell.timeLabel.text = onSaleProducts[indexPath.section].update.convertTimestamp()
            cell.priceLabel.text = onSaleProducts[indexPath.section].price
            
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "boughtCell") as? FinishedTableViewCell else { return UITableViewCell() }
            
            FirebaseManager.shared.downloadImagesTest(url: finishedProducts[indexPath.section].imagesURL[0]) { image in
                DispatchQueue.main.async {
                    cell.productImageView.image = image?.resizeThumbnailTo()
                }
            }
            
            if finishedProducts[indexPath.section].isSellerReview ?? false {
                cell.sendButton.setTitle("보낸 후기 보기", for: .normal)
                cell.sendButton.tag = indexPath.section
            } else {
                cell.sendButton.setTitle("후기 보내기", for: .normal)
                cell.sendButton.tag = indexPath.section
            }
            
            cell.addButton.tag = indexPath.section
            
            cell.delegate = self
            
            cell.titleLabel.text = finishedProducts[indexPath.section].title
            cell.addressLabel.text = finishedProducts[indexPath.section].address
            cell.timeLabel.text = finishedProducts[indexPath.section].update.convertTimestamp()
            cell.priceLabel.text = finishedProducts[indexPath.section].price
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "hideCell") as? HideTableViewCell else { return UITableViewCell() }
            
            FirebaseManager.shared.downloadImagesTest(url: hideProducts[indexPath.section].imagesURL[0]) { image in
                DispatchQueue.main.async {
                    cell.productImageView.image = image?.resizeThumbnailTo()
                }
            }
            
            cell.addButton.tag = indexPath.section
            cell.restoreHideButton.tag = indexPath.section
            
            cell.delegate = self
            
            cell.restoreHideButton.tag = indexPath.section
            cell.titleLabel.text = hideProducts[indexPath.section].title
            cell.addressLabel.text = hideProducts[indexPath.section].address
            cell.timeLabel.text = hideProducts[indexPath.section].update.convertTimestamp()
            cell.priceLabel.text = hideProducts[indexPath.section].price
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension MyProductsListViewController: OnSaleCellDelegate {
    func tapReservationButton(index: Int) {
        
        // 판매중인 상태
        if !onSaleProducts[index].isReservation {
            db.collection("게시글").document(onSaleProducts[index].productId).updateData(["reservation": true])
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "reservationVC") as? ReservationViewController else { return }
            vc.productId = onSaleProducts[index].productId
            vc.productTitle = onSaleProducts[index].title
            self.navigationController?.pushViewController(vc, animated:true)
        } else { // 예약중인 상태
            db.collection("게시글").document(onSaleProducts[index].productId).updateData(["reservation": FieldValue.delete()])
            db.collection("게시글").document(onSaleProducts[index].productId).updateData(["reservationUser": FieldValue.delete()])
        }
        
        FirebaseManager.shared.getProductsId(phoneNumber: userPhoneNumber) { onSaleList, finishedList, hideList in
            self.onSaleProducts = onSaleList
            self.finishedProducts = finishedList
            self.hideProducts = hideList
            
            DispatchQueue.main.async {
                self.onSaleTableView.reloadData()
                self.finishedTableView.reloadData()
                self.hideTableView.reloadData()
            }
        }
    }
    
    func tapFinishTransationButton(index: Int) {
        
        if onSaleProducts[index].isReservation == false {
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "FinishTranscationVC") as? FinishTransactionViewController else { return }
            vc.productId = onSaleProducts[index].productId
            vc.productTitle = onSaleProducts[index].title
            vc.productPrice = onSaleProducts[index].price
            
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            if onSaleProducts[index].reservationUser == "" {
                guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "FinishTranscationVC") as? FinishTransactionViewController else { return }
                vc.productId = onSaleProducts[index].productId
                vc.productTitle = onSaleProducts[index].title
                vc.productPrice = onSaleProducts[index].price
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                FirebaseManager.shared.getUserData(userPhoneNumber: self.onSaleProducts[index].reservationUser) { user in
                    
                    let reservationUser = ReservationChattingUserModel(phoneNumber: user?.phoneNumber ?? "", nickname: user?.nickname ?? "", profileImageUrl: nil, address: nil, lastUpdate: nil)
                    
                    guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "selectReviewVC") as? ReviewViewController else { return }
                    vc.productId = self.onSaleProducts[index].productId
                    vc.productTitle = self.onSaleProducts[index].title
                    vc.otherUser = reservationUser
                    vc.vcType = "sela"
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        
        db.collection("게시글").document(self.onSaleProducts[index].productId).updateData(["status": ProductStatusType.finished.rawValue])
        
        FirebaseManager.shared.getProductsId(phoneNumber: userPhoneNumber) { onSaleList, finishedList, hideList in
            self.onSaleProducts = onSaleList
            self.finishedProducts = finishedList
            self.hideProducts = hideList
            
            DispatchQueue.main.async {
                self.onSaleTableView.reloadData()
                self.finishedTableView.reloadData()
                self.hideTableView.reloadData()
            }
        }
        
    }
    
    func tapOnSaleAddButton(index: Int) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let edit = UIAlertAction(title: "게시글 수정", style: .default) { _ in
            
            let storyboard = UIStoryboard(name: "ProductList", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "registraionVC") as? ProductRegistraionViewController else { return }
            vc.vcType = "edit"
            vc.productData = self.onSaleProducts[index]
            
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        
        let hide = UIAlertAction(title: "숨기기", style: .default) { _ in
            self.db.collection("게시글").document(self.onSaleProducts[index].productId).updateData(["status": ProductStatusType.onSaleHide.rawValue])
            FirebaseManager.shared.getProductsId(phoneNumber: self.userPhoneNumber) { onSaleList, finishedList, hideList in
                self.onSaleProducts = onSaleList
                self.finishedProducts = finishedList
                self.hideProducts = hideList
                
                DispatchQueue.main.async {
                    self.onSaleTableView.reloadData()
                    self.finishedTableView.reloadData()
                    self.hideTableView.reloadData()
                }
            }
        }
        
        let delete = UIAlertAction(title: "삭제", style: .destructive) { _ in
            
            self.db.collection("유저정보").document(self.userPhoneNumber).updateData(["products": FieldValue.arrayRemove([self.onSaleProducts[index].productId])]) { error in
                if let error = error {
                    print("현재 상품 판매 목록에서 삭제 실패", error)
                }
                
                self.db.collection("게시글").document(self.onSaleProducts[index].productId).delete { error in
                    if let error = error {
                        print("게시글 삭제 실패", error)
                    }
                    
                    FirebaseManager.shared.getProductsId(phoneNumber: self.userPhoneNumber) { onSaleList, finishList, hideList in
                        
                        self.onSaleProducts = onSaleList
                        self.finishedProducts = finishList
                        self.hideProducts = hideList
                        
                        DispatchQueue.main.async {
                            self.onSaleTableView.reloadData()
                            self.finishedTableView.reloadData()
                            self.hideTableView.reloadData()
                        }
                    }
                }
            }
        }
        
        let close = UIAlertAction(title: "닫기", style: .cancel)
        
        alert.addAction(edit)
        alert.addAction(hide)
        alert.addAction(delete)
        alert.addAction(close)
        
        self.present(alert, animated: true)
    }
}


extension MyProductsListViewController: FinishedCellDelegate {
    func tapSendButton(index: Int, title: String) {
        if title == "후기 보내기" {
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "FinishTranscationVC") as? FinishTransactionViewController else { return }
            vc.productId = finishedProducts[index].productId
            vc.productTitle = finishedProducts[index].title
            vc.productPrice = finishedProducts[index].price
            
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            // 리뷰 결과 보기
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "sendReviewVC") as? SendReviewViewController else { return }
            vc.vcType = "sela"
            vc.productData = finishedProducts[index]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tapFinishedAddButton(index: Int) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let onSale = UIAlertAction(title: "판매중", style: .default) { _ in
            
            if self.finishedProducts[index].buyer == "" {
                self.db.collection("게시글").document(self.finishedProducts[index].productId).updateData(["status": ProductStatusType.onSale.rawValue]) { error in
                    if let error = error {
                        print("상품 상태 업데이트 실패", error)
                    }
                    
                    FirebaseManager.shared.getProductsId(phoneNumber: self.userPhoneNumber) { onSaleList, finishList, hideList in
                        
                        self.onSaleProducts = onSaleList
                        self.finishedProducts = finishList
                        self.hideProducts = hideList
                        
                        DispatchQueue.main.async {
                            self.onSaleTableView.reloadData()
                            self.finishedTableView.reloadData()
                            self.hideTableView.reloadData()
                        }
                    }
                }
            } else {
                self.db.collection("게시글").document(self.finishedProducts[index].productId).getDocument { snapShot, error in
                    if let error = error {
                        print("게시글 데이터 가져오기 실패", error)
                    }
                    
                    guard let buyerReview = snapShot?.data()?["buyerReview"] as? Bool else { return }
                    
                    // 구매자가 리뷰 작성 했으면
                    if buyerReview {
                        //구매자,판매자 모두 리뷰 작성 했을때
                        // 구매자, 판매자 리뷰 정보 삭제
                        
                        // 구매자 매너 평가 목록 가져오기
                        self.db.collection("유저정보").document(self.finishedProducts[index].buyer).collection("매너평가").document("\(self.finishedProducts[index].productId)-\(self.finishedProducts[index].phoneNumber)").getDocument { snapShot, error in
                            if let error = error {
                                print("구매자 매너 평가 목록 가져오기 실패",error)
                            }
                            
                            guard let buyerReviewsData = snapShot?.data() else { return }
                            
                            // 판매자 매너 평가 목록 가져오기
                            self.db.collection("유저정보").document(self.finishedProducts[index].phoneNumber).collection("매너평가").document("\(self.finishedProducts[index].productId)-\(self.finishedProducts[index].buyer)").getDocument { snapShot, error in
                                if let error = error {
                                    print("판매자 매너 평가 목록 가져오기 실패",error)
                                }
                                
                                guard let sellerReviewData = snapShot?.data() else { return }
                                
                                // 구매자 매너 평가 목록 삭제
                                self.db.collection("유저정보").document(self.finishedProducts[index].buyer).collection("매너평가").document("\(self.finishedProducts[index].productId)-\(self.finishedProducts[index].phoneNumber)").delete { error in
                                    if let error = error {
                                        print("구매자 매너평가 목록 삭제 실패", error)
                                    }
                                    
                                    // 판매자 매너 평가 목록 삭제
                                    self.db.collection("유저정보").document(self.finishedProducts[index].phoneNumber).collection("매너평가").document("\(self.finishedProducts[index].productId)-\(self.finishedProducts[index].buyer)").delete { error in
                                        if let error = error {
                                            print("판매자 매너평가 목록 삭제 실패", error)
                                        }
                                        
                                        // 구매자 리뷰 카운트 가져오기
                                        self.db.collection("유저정보").document(self.finishedProducts[index].buyer).getDocument { snapShot, error in
                                            if let error = error {
                                                print("구매자 리뷰 카운트 가져오기 실패",error)
                                            }
                                            
                                            guard let buyerReviewsCount = snapShot?.data()?["reviewsCount"] as? [String:Int] else { return }
                                            var resultReviewsCount = buyerReviewsCount
                                            for i in buyerReviewsData {
                                                resultReviewsCount[i.key] = ((buyerReviewsCount[i.key] ?? 0) - 1)
                                            }
                                            
                                            
                                            // 판매자 리뷰 카운트 가져오기
                                            self.db.collection("유저정보").document(self.finishedProducts[index].phoneNumber).getDocument { snapShot, error in
                                                if let error = error {
                                                    print("판매자 리뷰 카운트 가져오기 실패", error)
                                                }
                                                
                                                guard var sellerReviewsCount = snapShot?.data()?["reviewsCount"] as? [String:Int] else { return }
                                                
                                                for i in sellerReviewData {
                                                    sellerReviewsCount[i.key] = ((sellerReviewsCount[i.key] ?? 0) - 1)
                                                }
                                                
                                                // 계산된 구매자 리뷰 카운트, 구매목록에서 상품 삭제 업데이트
                                                self.db.collection("유저정보").document(self.finishedProducts[index].buyer).updateData(["reviewsCount": resultReviewsCount,
                                                                                                                                    "finishProducts": FieldValue.delete()]) { error in
                                                    if let error = error {
                                                        print("구매자 데이터 업데이트 실패", error)
                                                    }
                                                    
                                                    // 계산된 판매자 리뷰 카운트 업데이트
                                                    self.db.collection("유저정보").document(self.finishedProducts[index].phoneNumber).updateData(["reviewsCount": sellerReviewsCount]) { error in
                                                        if let error = error {
                                                            print("판매자 리뷰 카운트 업데이트 실패", error)
                                                        }
                                                        
                                                        // 판매자는 판매상품정보에서 상품상태, 판매자 리뷰작성 상태, 구매자정보, 예약자 정보, 예약 상태, 구매자 리뷰작성 상태 업데이트
                                                        self.db.collection("게시글").document(self.finishedProducts[index].productId).updateData(
                                                            ["status": ProductStatusType.onSale.rawValue,
                                                             "sellerReview": FieldValue.delete(),
                                                             "buyer": FieldValue.delete(),
                                                             "reservation":FieldValue.delete(),
                                                             "reservationUser": FieldValue.delete(),
                                                             "buyerReview": FieldValue.delete()]) { error in
                                                                 if let error = error {
                                                                     print("판매자 게시글 데이터 업데이트 실패",error)
                                                                 }
                                                                 
                                                                 FirebaseManager.shared.getProductsId(phoneNumber: self.userPhoneNumber) { onSaleList, finishList, hideList in
                                                                     
                                                                     self.onSaleProducts = onSaleList
                                                                     self.finishedProducts = finishList
                                                                     self.hideProducts = hideList
                                                                     
                                                                     DispatchQueue.main.async {
                                                                         self.onSaleTableView.reloadData()
                                                                         self.finishedTableView.reloadData()
                                                                         self.hideTableView.reloadData()
                                                                     }
                                                                 }
                                                             }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else { // 구매자가 리뷰작성 하지 않았으면
                        
                        // 구매자 매너평가 목록 가져오기
                        self.db.collection("유저정보").document(self.finishedProducts[index].buyer).collection("매너평가").document("\(self.finishedProducts[index].productId)-\(self.userPhoneNumber)").getDocument { snapShot, error in
                            if let error = error {
                                print("매너평가 목록 가져오기 실패", error)
                            }
                            
                            guard let reviewsData = snapShot?.data() else { return }
                            
                            // 리뷰 카운트 가져오기
                            self.db.collection("유저정보").document(self.finishedProducts[index].buyer).getDocument { snapShot, error in
                                if let error = error {
                                    print("리뷰 카운트 가져오기 실패", error)
                                }
                                
                                // 리뷰 카운트 계산
                                guard let reviewsCount = snapShot?.data()?["reviewsCount"] as? [String : Int] else { return }
                                var resultReviewsCount = reviewsCount
                                
                                for i in reviewsData {
                                    resultReviewsCount[i.key] = ((reviewsCount[i.key] ?? 0) - 1)
                                }
                                
                                // 매너 평가 목록 삭제
                                self.db.collection("유저정보").document(self.finishedProducts[index].buyer).collection("매너평가").document("\(self.finishedProducts[index].productId)-\(self.userPhoneNumber)").delete { error in
                                    
                                    if let error = error {
                                        print("매너평가 삭제 실패", error)
                                    }
                                    
                                    // 구매자 정보에서 리뷰카운트, 구매완료상품 삭제 업데이트
                                    self.db.collection("유저정보").document(self.finishedProducts[index].buyer).updateData(["reviewsCount": resultReviewsCount,
                                                                                                                        "finishProducts":FieldValue.delete()]) { error in
                                        if let error = error {
                                            print("리뷰 카운트 업데이트 실패", error)
                                        }
                                        
                                        
                                        // 상품 상태 변경, 판매자 리뷰 상태 삭제, 구매자 삭제, 구매자 리뷰 상태 삭제
                                        self.db.collection("게시글").document(self.finishedProducts[index].productId).updateData(["status": ProductStatusType.onSale.rawValue,
                                                                                                                               "sellerReview": FieldValue.delete(),
                                                                                                                               "buyer": FieldValue.delete(),
                                                                                                                               "reservation": FieldValue.delete(),
                                                                                                                               "reservationUser": FieldValue.delete(),
                                                                                                                               "buyerReview": FieldValue.delete()]) { error in
                                            if let error = error {
                                                print("상품 상태 변경, 판매자 리뷰 상태 삭제, 구매자 삭제, 구매자 리뷰 상태 삭제 실패", error)
                                            }
                                            
                                            FirebaseManager.shared.getProductsId(phoneNumber: self.userPhoneNumber) { onSaleList, finishList, hideList in
                                                
                                                self.onSaleProducts = onSaleList
                                                self.finishedProducts = finishList
                                                self.hideProducts = hideList
                                                
                                                DispatchQueue.main.async {
                                                    self.onSaleTableView.reloadData()
                                                    self.finishedTableView.reloadData()
                                                    self.hideTableView.reloadData()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        let edit = UIAlertAction(title: "게시글 수정", style: .default) { _ in
            let storyboard = UIStoryboard(name: "ProductList", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "registraionVC") as? ProductRegistraionViewController else { return }
            vc.vcType = "edit"
            vc.productData = self.finishedProducts[index]
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
        let hide = UIAlertAction(title: "숨기기", style: .default) { _ in
            self.db.collection("게시글").document(self.finishedProducts[index].productId).updateData(["status": ProductStatusType.finishedHide.rawValue])
            FirebaseManager.shared.getProductsId(phoneNumber: self.userPhoneNumber) { onSaleList, finishedList, hideList in
                self.onSaleProducts = onSaleList
                self.finishedProducts = finishedList
                self.hideProducts = hideList
                
                self.onSaleTableView.reloadData()
                self.finishedTableView.reloadData()
                self.hideTableView.reloadData()
            }
        }
        let delete = UIAlertAction(title: "삭제", style: .destructive) { _ in
            
            // 구매자가 없으면 바로 게시글 삭제
            if self.finishedProducts[index].buyer == "" {
                self.db.collection("게시글").document(self.finishedProducts[index].productId).delete { error in
                    if let error = error {
                        print("게시글 삭제 실패", error)
                    }
                    
                    self.db.collection("유저정보").document(self.userPhoneNumber).updateData(["products": FieldValue.arrayRemove([self.finishedProducts[index].productId])]) { error in
                        if let error = error {
                            print("현재 상품 판매 목록에서 삭제 실패", error)
                        }
                        
                        FirebaseManager.shared.getProductsId(phoneNumber: self.userPhoneNumber) { onSaleList, finishList, hideList in
                            
                            self.onSaleProducts = onSaleList
                            self.finishedProducts = finishList
                            self.hideProducts = hideList
                            
                            DispatchQueue.main.async {
                                self.onSaleTableView.reloadData()
                                self.finishedTableView.reloadData()
                                self.hideTableView.reloadData()
                            }
                        }
                    }
                }
            } else {
                // 구매자가 선택되있을경우
                self.db.collection("게시글").document(self.finishedProducts[index].productId).getDocument { snapShot, error in
                    if let error = error {
                        print("게시글 데이터 가져오기 실패", error)
                    }
                    
                    guard let buyerReview = snapShot?.data()?["buyerReview"] as? Bool else { return }
                    
                    // 구매자가 리뷰 작성 했으면
                    if buyerReview {
                        //구매자,판매자 모두 리뷰 작성 했을때
                        // 구매자, 판매자 리뷰 정보 삭제
                        
                        // 구매자 매너 평가 목록 가져오기
                        self.db.collection("유저정보").document(self.finishedProducts[index].buyer).collection("매너평가").document("\(self.finishedProducts[index].productId)-\(self.finishedProducts[index].phoneNumber)").getDocument { snapShot, error in
                            if let error = error {
                                print("구매자 매너 평가 목록 가져오기 실패",error)
                            }
                            
                            guard let buyerReviewsData = snapShot?.data() else { return }
                            
                            // 판매자 매너 평가 목록 가져오기
                            self.db.collection("유저정보").document(self.finishedProducts[index].phoneNumber).collection("매너평가").document("\(self.finishedProducts[index].productId)-\(self.finishedProducts[index].buyer)").getDocument { snapShot, error in
                                if let error = error {
                                    print("판매자 매너 평가 목록 가져오기 실패",error)
                                }
                                
                                guard let sellerReviewData = snapShot?.data() else { return }
                                
                                // 구매자 매너 평가 목록 삭제
                                self.db.collection("유저정보").document(self.finishedProducts[index].buyer).collection("매너평가").document("\(self.finishedProducts[index].productId)-\(self.finishedProducts[index].phoneNumber)").delete { error in
                                    if let error = error {
                                        print("구매자 매너평가 목록 삭제 실패", error)
                                    }
                                    
                                    // 판매자 매너 평가 목록 삭제
                                    self.db.collection("유저정보").document(self.finishedProducts[index].phoneNumber).collection("매너평가").document("\(self.finishedProducts[index].productId)-\(self.finishedProducts[index].buyer)").delete { error in
                                        if let error = error {
                                            print("판매자 매너평가 목록 삭제 실패", error)
                                        }
                                        
                                        // 구매자 리뷰 카운트 가져오기
                                        self.db.collection("유저정보").document(self.finishedProducts[index].buyer).getDocument { snapShot, error in
                                            if let error = error {
                                                print("구매자 리뷰 카운트 가져오기 실패",error)
                                            }
                                            
                                            guard let buyerReviewsCount = snapShot?.data()?["reviewsCount"] as? [String:Int] else { return }
                                            var resultReviewsCount = buyerReviewsCount
                                            for i in buyerReviewsData {
                                                resultReviewsCount[i.key] = ((buyerReviewsCount[i.key] ?? 0) - 1)
                                            }
                                            
                                            
                                            // 판매자 리뷰 카운트 가져오기
                                            self.db.collection("유저정보").document(self.finishedProducts[index].phoneNumber).getDocument { snapShot, error in
                                                if let error = error {
                                                    print("판매자 리뷰 카운트 가져오기 실패", error)
                                                }
                                                
                                                guard var sellerReviewsCount = snapShot?.data()?["reviewsCount"] as? [String:Int] else { return }
                                                
                                                for i in sellerReviewData {
                                                    sellerReviewsCount[i.key] = ((sellerReviewsCount[i.key] ?? 0) - 1)
                                                }
                                                
                                                // 계산된 구매자 리뷰 카운트, 구매목록에서 상품 삭제 업데이트
                                                self.db.collection("유저정보").document(self.finishedProducts[index].buyer).updateData(["reviewsCount": resultReviewsCount,
                                                                                                                                    "finishProducts": FieldValue.delete()]) { error in
                                                    if let error = error {
                                                        print("구매자 데이터 업데이트 실패", error)
                                                    }
                                                    
                                                    // 계산된 판매자 리뷰 카운트 업데이트
                                                    self.db.collection("유저정보").document(self.finishedProducts[index].phoneNumber).updateData(["reviewsCount": sellerReviewsCount]) { error in
                                                        if let error = error {
                                                            print("판매자 리뷰 카운트 업데이트 실패", error)
                                                        }
                                                        
                                                        // 판매자는 판매상품정보에서 상품상태, 판매자 리뷰작성 상태, 구매자정보, 예약자 정보, 예약 상태, 구매자 리뷰작성 상태 업데이트
                                                        self.db.collection("게시글").document(self.finishedProducts[index].productId).updateData(
                                                            ["status": ProductStatusType.onSale.rawValue,
                                                             "sellerReview": FieldValue.delete(),
                                                             "buyer": FieldValue.delete(),
                                                             "reservation":FieldValue.delete(),
                                                             "reservationUser": FieldValue.delete(),
                                                             "buyerReview": FieldValue.delete()]) { error in
                                                                 if let error = error {
                                                                     print("판매자 게시글 데이터 업데이트 실패",error)
                                                                 }
                                                                 
                                                                 self.db.collection("유저정보").document(self.userPhoneNumber).updateData(["products": FieldValue.arrayRemove([self.finishedProducts[index].productId])]) { error in
                                                                     if let error = error {
                                                                         print("현재 상품 판매 목록에서 삭제 실패", error)
                                                                     }
                                                                     
                                                                     self.db.collection("게시글").document(self.finishedProducts[index].productId).delete { error in
                                                                         if let error = error {
                                                                             print("게시글 삭제 실패", error)
                                                                         }
                                                                         FirebaseManager.shared.getProductsId(phoneNumber: self.userPhoneNumber) { onSaleList, finishList, hideList in
                                                                             
                                                                             self.onSaleProducts = onSaleList
                                                                             self.finishedProducts = finishList
                                                                             self.hideProducts = hideList
                                                                             
                                                                             DispatchQueue.main.async {
                                                                                 self.onSaleTableView.reloadData()
                                                                                 self.finishedTableView.reloadData()
                                                                                 self.hideTableView.reloadData()
                                                                             }
                                                                         }
                                                                     }
                                                                 }
                                                             }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else { // 구매자가 리뷰작성 하지 않았으면
                        
                        // 구매자 매너평가 목록 가져오기
                        self.db.collection("유저정보").document(self.finishedProducts[index].buyer).collection("매너평가").document("\(self.finishedProducts[index].productId)-\(self.userPhoneNumber)").getDocument { snapShot, error in
                            if let error = error {
                                print("매너평가 목록 가져오기 실패", error)
                            }
                            
                            guard let reviewsData = snapShot?.data() else { return }
                            
                            // 리뷰 카운트 가져오기
                            self.db.collection("유저정보").document(self.finishedProducts[index].buyer).getDocument { snapShot, error in
                                if let error = error {
                                    print("리뷰 카운트 가져오기 실패", error)
                                }
                                
                                // 리뷰 카운트 계산
                                guard let reviewsCount = snapShot?.data()?["reviewsCount"] as? [String : Int] else { return }
                                var resultReviewsCount = reviewsCount
                                
                                for i in reviewsData {
                                    resultReviewsCount[i.key] = ((reviewsCount[i.key] ?? 0) - 1)
                                }
                                
                                // 매너 평가 목록 삭제
                                self.db.collection("유저정보").document(self.finishedProducts[index].buyer).collection("매너평가").document("\(self.finishedProducts[index].productId)-\(self.userPhoneNumber)").delete { error in
                                    
                                    if let error = error {
                                        print("매너평가 삭제 실패", error)
                                    }
                                    
                                    // 구매자 정보에서 리뷰카운트, 구매완료상품 삭제 업데이트
                                    self.db.collection("유저정보").document(self.finishedProducts[index].buyer).updateData(["reviewsCount": resultReviewsCount,
                                                                                                                        "finishProducts":FieldValue.delete()]) { error in
                                        if let error = error {
                                            print("리뷰 카운트 업데이트 실패", error)
                                        }
                                        
                                        
                                        // 상품 상태 변경, 판매자 리뷰 상태 삭제, 구매자 삭제, 구매자 리뷰 상태 삭제
                                        self.db.collection("게시글").document(self.finishedProducts[index].productId).updateData(["status": ProductStatusType.onSale.rawValue,
                                                                                                                               "sellerReview": FieldValue.delete(),
                                                                                                                               "buyer": FieldValue.delete(),
                                                                                                                               "reservation": FieldValue.delete(),
                                                                                                                               "reservationUser": FieldValue.delete(),
                                                                                                                               "buyerReview": FieldValue.delete()]) { error in
                                            if let error = error {
                                                print("상품 상태 변경, 판매자 리뷰 상태 삭제, 구매자 삭제, 구매자 리뷰 상태 삭제 실패", error)
                                            }
                                            
                                            
                                            self.db.collection("유저정보").document(self.userPhoneNumber).updateData(["products": FieldValue.arrayRemove([self.finishedProducts[index].productId])]) { error in
                                                if let error = error {
                                                    print("현재 상품 판매 목록에서 삭제 실패", error)
                                                }
                                                
                                                self.db.collection("게시글").document(self.finishedProducts[index].productId).delete { error in
                                                    if let error = error {
                                                        print("게시글 삭제 실패", error)
                                                    }
                                                    
                                                    FirebaseManager.shared.getProductsId(phoneNumber: self.userPhoneNumber) { onSaleList, finishList, hideList in
                                                        
                                                        self.onSaleProducts = onSaleList
                                                        self.finishedProducts = finishList
                                                        self.hideProducts = hideList
                                                        
                                                        DispatchQueue.main.async {
                                                            self.onSaleTableView.reloadData()
                                                            self.finishedTableView.reloadData()
                                                            self.hideTableView.reloadData()
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        let cancel = UIAlertAction(title: "닫기", style: .cancel)
        
        alert.addAction(onSale)
        alert.addAction(edit)
        alert.addAction(hide)
        alert.addAction(delete)
        alert.addAction(cancel)
        
        self.present(alert, animated: true)
        
    }
}

extension MyProductsListViewController: HideCellDelegate {
    func tapRestoreHideButton(index: Int) {
        
        if hideProducts[index].status == ProductStatusType.onSaleHide.rawValue {
            db.collection("게시글").document(hideProducts[index].productId).updateData(["status": ProductStatusType.onSale.rawValue])
        } else if hideProducts[index].status == ProductStatusType.finishedHide.rawValue {
            db.collection("게시글").document(hideProducts[index].productId).updateData(["status": ProductStatusType.finished.rawValue])
        }
        
        FirebaseManager.shared.getProductsId(phoneNumber: self.userPhoneNumber) { onSaleList, finishedList, hideList in
            self.onSaleProducts = onSaleList
            self.finishedProducts = finishedList
            self.hideProducts = hideList
            
            self.onSaleTableView.reloadData()
            self.finishedTableView.reloadData()
            self.hideTableView.reloadData()
        }
    }
    
    func tapHideAddButton(index: Int) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let edit = UIAlertAction(title: "게시글 수정", style: .default) { _ in
            
        }
        let delete = UIAlertAction(title: "삭제", style: .destructive) { _ in
            self.db.collection("게시글").document(self.hideProducts[index].productId).delete()
            FirebaseManager.shared.getProductsId(phoneNumber: self.userPhoneNumber) { onSaleList, finishedList, hideList in
                self.onSaleProducts = onSaleList
                self.finishedProducts = finishedList
                self.hideProducts = hideList
                
                self.onSaleTableView.reloadData()
                self.finishedTableView.reloadData()
                self.hideTableView.reloadData()
            }
        }
        let cancel = UIAlertAction(title: "닫기", style: .cancel)
        
        alert.addAction(edit)
        alert.addAction(delete)
        alert.addAction(cancel)
        
        self.present(alert, animated: true)
    }
}
