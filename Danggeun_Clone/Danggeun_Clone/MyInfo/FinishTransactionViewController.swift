//
//  FinishTransactionViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/08/03.
//

import UIKit
import FirebaseFirestore

class FinishTransactionViewController: UIViewController {

    @IBOutlet var finishTranactionTableView: UITableView!
    @IBOutlet var finishTableFooterView: UIView!
    
    let db = Firestore.firestore()
    
    var productId: String?
    var productTitle: String?
    var productPrice: String?

    var reservationUser: ReservationChattingUserModel?
    
    var chattingUsers = [ReservationChattingUserModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchChattingUsers()
    }
    
    func fetchChattingUsers() {
        db.collection("채팅").whereField("productId", isEqualTo: productId ?? "").getDocuments { snapShot, error in
            if let error = error {
                print("채팅 정보 가져오기 실패", error)
            }
            
            guard let documents = snapShot?.documents else { return }
            
            if !documents.isEmpty {
                var count = 0
                documents.forEach({
                    let lastUpdate = $0.data()["lastUpdate"] as! Timestamp
                    
                    FirebaseManager.shared.getUserData(userPhoneNumber: $0.data()["buyer"] as? String ?? "") { user in
                        let chattingUser = ReservationChattingUserModel(phoneNumber: user?.phoneNumber ?? "",
                                                                        nickname: user?.nickname ?? "",
                                                                        profileImageUrl: user?.profileImageUrl ?? "",
                                                                        address: user?.selectedAddress ?? "",
                                                                        lastUpdate: lastUpdate)
                        
                        self.chattingUsers.append(chattingUser)
                        count += 1
                        
                        if count == documents.count {
                            DispatchQueue.main.async {
                                self.finishTableFooterView.isHidden = true
                                self.finishTranactionTableView.reloadData()
                            }
                        }
                    }
                })
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nextVC = segue.destination as? ReviewViewController else { return }
        
        if let selectIndex = finishTranactionTableView.indexPathForSelectedRow?.row {
            nextVC.otherUser = chattingUsers[selectIndex]
            nextVC.productTitle = productTitle
            nextVC.productId = productId
            nextVC.vcType = "sela"
        }
    }
}

extension FinishTransactionViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return chattingUsers.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "productInfoCell", for: indexPath) as? FinishTransactionProductInfoTableViewCell else { return UITableViewCell() }
            cell.productTitleLabel.text = productTitle
            cell.productPriceLabel.text = productPrice == "" ? "가격없음" : "\(productPrice ?? "") 원"
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "finishTransactionUserProfileCell", for: indexPath) as? FinishTransactionUserProfileTableViewCell else { return UITableViewCell() }
            cell.nicknameLabel.text = chattingUsers[indexPath.row].nickname
            cell.addressLabel.text = chattingUsers[indexPath.row].address
            cell.lastUpdateLabel.text = "마지막 대화 \(chattingUsers[indexPath.row].lastUpdate?.convertTimestamp() ?? "") 전"
            
            FirebaseManager.shared.downloadImagesTest(url: chattingUsers[indexPath.row].profileImageUrl ?? "") { image in
                DispatchQueue.main.async {
                    cell.profileImageView.image = image == nil ? UIImage(named: "swift") : image?.resizeThumbnailTo()
                }
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
}
