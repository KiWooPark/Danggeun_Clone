//
//  ReViewViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/08/17.
//

import UIKit
import FirebaseFirestore

class ReviewViewController: UIViewController, ReviewDelegate, CommentDelegate {

    func changeCommentState(tag: Int) {
        // tag = 100, 101, 102
        selectCommentState = tag
        
        guard let badCommentCell = reviewTableView.dequeueReusableCell(withIdentifier: "badCommentCell") as? BadCommentTableViewCell else { return }
        guard let ganeralCommentCell = reviewTableView.dequeueReusableCell(withIdentifier: "generalCommentCell") as? GeneralCommentTableViewCell else { return }
        guard let goodCommentCell = reviewTableView.dequeueReusableCell(withIdentifier: "goodCommentCell") as? GoodCommentTableViewCell else { return }
        badCommentCell.commentButton.forEach({$0.isSelected = false})
        ganeralCommentCell.commentButton.forEach({$0.isSelected = false})
        ganeralCommentCell.commentTextView.text = ""
        goodCommentCell.commentButton.forEach({$0.isSelected = false})
        goodCommentCell.commentTextView.text = ""
        
        
        reviewTableView.reloadRows(at: [IndexPath(row: 0, section: 2)], with: .none)
    }
    
    func selectComment(buttons: [Int:Bool]) {
        commentStates = buttons
    }
    
    func sendPreference(comment: String?) {
    
        let commentNumbers = commentStates.enumerated().filter({$1.value}).map({$0.element.key})
        
        var reviewsData = [String: String]()
        
        reviewsData.removeAll()
        
        for number in commentNumbers {
            switch number {
            case 0:
                reviewsData["0"] = "이 분과 다시는 거래하고 싶지 않아요."
            case 1:
                reviewsData["1"] = "원하지 않는 가격을 계속 요구해요."
            case 2:
                reviewsData["2"] = "시간 약속을 안지켜요."
            case 3:
                reviewsData["3"] = "채팅 메시지를 읽고도 답이 없어요."
            case 4:
                reviewsData["4"] = "불친절해요."
            case 5:
                reviewsData["5"] = "제가 있는 곳까지 와서 거래했어요."
            case 6:
                reviewsData["6"] = "친절하고 매너가 좋아요."
            case 7:
                reviewsData["7"] = "시간 약속을 잘 지켜요."
            case 8:
                reviewsData["8"] = "응답이 빨라요."
            default:
                break
            }
        }
        
        if comment != "" {
            reviewsData["9"] = comment
        }
        
        // 구매내역에서 후기 보내기
        if vcType == "buyer" {
            db.collection("게시글").document(productId ?? "").getDocument { snapShot, error in
                if let error = error {
                    print("게시글 가져오기 실패", error)
                }
                
                guard let status = snapShot?.data()?["status"] as? String else { return }
                
                // 판매중 상태이면
                if status == ProductStatusType.onSale.rawValue {
                    print("후기를 보낼수 없습니다.")
                    
                } else { // 거래완료 상태이면
                    // 판매자 리뷰 카운트 가져오기
                    self.db.collection("유저정보").document(self.otherUser?.phoneNumber ?? "").getDocument { snapShot, error in
                        if let error = error {
                            print("판매자 리뷰 카운트 가져오기 실패", error)
                        }
                        
                        var resultReviewsCount = [String: Int]()
                        // 판매자 리뷰 카운트 계산하기
                        if let reviewsCount = snapShot?.data()?["reviewsCount"] as? [String: Int] {
                            resultReviewsCount = reviewsCount
                            for i in reviewsData {
                                resultReviewsCount[i.key] = ((reviewsCount[i.key] ?? 0) + 1)
                            }
                        } else {
                            resultReviewsCount = ["0": 0,"1": 0,"2": 0,"3": 0,"4": 0,"5": 0,"6": 0,"7": 0,"8": 0]
                            for i in reviewsData {
                                resultReviewsCount[i.key] = ((resultReviewsCount[i.key] ?? 0) + 1)
                            }
                        }
                        
                        // 판매자 리뷰 카운트 업데이트하기
                        self.db.collection("유저정보").document(self.otherUser?.phoneNumber ?? "").updateData(["reviewsCount": resultReviewsCount]) { error in
                            if let error = error {
                                print("판매자 리뷰 카운트 업데이트 실패", error)
                            }
                            
                            // 판매자 매너평가에 구매자가 평가한 내용 업데이트
                            self.db.collection("유저정보").document(self.otherUser?.phoneNumber ?? "").collection("매너평가").document("\(self.productId ?? "")-\(UserModel.getUserData()?.phoneNumber ?? "")").setData(reviewsData) { error in
                                if let error = error {
                                    print("매너평가 업데이트 실패",error)
                                }
                                
                                // 게시글에 구매자 리뷰 상태 업데이트 
                                self.db.collection("게시글").document(self.productId ?? "").updateData(["buyerReview": true]) { error in
                                    if let error = error {
                                        print("구매자 리뷰 상태 업데이트 실패", error)
                                    }
                                }
                                
                                print("aaaaaadsasdasdasdasd")
                                // 구매내역 VC 리로드
                                guard let navigationViewStack = self.navigationController?.viewControllers else { return }
                                for viewController in navigationViewStack {
                                    if let rootVC = viewController as? BoughtListViewController {
                                        rootVC.fetchProducts()
                                        self.navigationController?.popViewController(animated: true)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else { // 판매내역에서 리뷰 보내기
            // 구매자 리뷰 카운트 가져오기
            
            print(self.otherUser?.phoneNumber)
            self.db.collection("유저정보").document(self.otherUser?.phoneNumber ?? "").getDocument { snapShot, error in
                if let error = error {
                    print("구매자 정보 가져오기 실패", error)
                }
                
                // 구매자 리뷰 카운트 계산하기
                var resultReviewsCount = [String: Int]()
                
                if let reviewsCount = snapShot?.data()?["reviewsCount"] as? [String: Int] {
                    resultReviewsCount = reviewsCount
                    for i in reviewsData {
                        resultReviewsCount[i.key] = ((reviewsCount[i.key] ?? 0) + 1)
                    }
                } else {
                    resultReviewsCount = ["0": 0,"1": 0,"2": 0,"3": 0,"4": 0,"5": 0,"6": 0,"7": 0,"8": 0]
                    for i in reviewsData {
                        resultReviewsCount[i.key] = ((resultReviewsCount[i.key] ?? 0) + 1)
                    }
                }
                
                // 구매자 리뷰 카운트 업데이트
                self.db.collection("유저정보").document(self.otherUser?.phoneNumber ?? "").updateData(["reviewsCount": resultReviewsCount]) { error in
                    if let error = error {
                        print("리뷰 카운트 업데이트 실패", error)
                    }
                    
                    //구매자 매너평가에 내가 평가한 내용 업데이트
                    self.db.collection("유저정보").document(self.otherUser?.phoneNumber ?? "").collection("매너평가").document("\(self.productId ?? "")-\(UserModel.getUserData()?.phoneNumber ?? "")").setData(reviewsData) { error in
                        if let error = error {
                            print("매너평가 업데이트 실패", error)
                        }
                        // 판매자 리뷰 작성상태 업데이트, 판매자 리뷰 상태 필드 생성, 구매자 정보 추가
                        self.db.collection("게시글").document(self.productId ?? "").updateData(["sellerReview": true,
                                                                                             "buyerReview": false,
                                                                                             "buyer": self.otherUser?.phoneNumber ?? ""]) { error in
                            if let error = error {
                                print("리뷰 상태 업데이트 실패", error)
                            }
                            
                            self.db.collection("유저정보").document(self.otherUser?.phoneNumber ?? "").updateData(["finishProducts": FieldValue.arrayUnion([self.productId ?? ""])]) { error in
                                if let error = error {
                                    print("구매자 정보에 구매상품 업데이트 실패",error)
                                }
                                
                                guard let navigationViewStack = self.navigationController?.viewControllers else { return }
                                for viewController in navigationViewStack {
                                    if let rootVC = viewController as? MyProductsListViewController {
                                        self.navigationController?.popToViewController(rootVC, animated: true)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
 
    @IBOutlet var reviewTableView: UITableView!
    
    var selectCommentState = 0
    var commentStates = [Int:Bool]()
    
    var db = Firestore.firestore()
    
    // 공용으로 받아올 데이터
    var vcType: String?
    var productTitle: String?
    var productId: String?
    var otherUser: ReservationChattingUserModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

extension ReviewViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
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
        
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "reviewProductInfoCell", for: indexPath) as? ReviewProductInfoTableViewCell else { return UITableViewCell() }
            cell.productTitleLabel.text = productTitle
            cell.nicknameLabel.text = otherUser?.nickname
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "reviewPreferenceCell", for: indexPath) as? ReviewPreferenceTableViewCell else { return UITableViewCell() }
            cell.reviewDelegate = self
            cell.myNicknameLabel.text = "\(UserModel.getUserData()?.nickname ?? "")님,"
            cell.anotherUserNicknameLabel.text = "\(otherUser?.nickname ?? "")님과 거래가 어떠셨나요?"
            return cell
        case 2:
            switch selectCommentState {
            case 100:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "badCommentCell", for: indexPath) as? BadCommentTableViewCell else { return UITableViewCell() }
                cell.badDelegate = self
                return cell
            case 101:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "generalCommentCell", for: indexPath) as? GeneralCommentTableViewCell else { return UITableViewCell() }
                cell.generalDelegate = self
                return cell
            case 102:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "goodCommentCell", for: indexPath) as? GoodCommentTableViewCell else { return UITableViewCell() }
                cell.goodDelegate = self
                return cell
            default:
                return UITableViewCell()
            }
        default:
            return UITableViewCell()
        }
    }
}
