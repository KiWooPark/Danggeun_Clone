//
//  ReservationViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/08/03.
//

import UIKit
import FirebaseFirestore

class ReservationViewController: UIViewController {

    @IBOutlet var reservationListTableView: UITableView!
    @IBOutlet var selectReservationButton: UIButton!
    
    @IBOutlet var centerView: UIView!
    
    let db = Firestore.firestore()
    
    var productId: String?
    var productTitle: String?
    
    var reservationUser: ReservationChattingUserModel?
    
    var chattingUsers = [ReservationChattingUserModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchChattingUser()
    }
    
    @IBAction func tapSelectReservationButton(_ sender: Any) {
        db.collection("게시글").document(productId ?? "").updateData(["reservationUser": reservationUser?.phoneNumber ?? ""])
        self.navigationController?.popViewController(animated: true)
    }
    
   
    func fetchChattingUser() {
        
        db.collection("채팅").whereField("productId", isEqualTo: productId ?? "").getDocuments { snapShot, error in
            
            if let error = error {
                print(error)
            }
            
            guard let documents = snapShot?.documents else { return }
            
            if documents.isEmpty {
                DispatchQueue.main.async {
                    self.centerView.alpha = 1.0
                    self.selectReservationButton.isEnabled = false
                }
            } else {
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
                                self.centerView.alpha = 0.0
                                self.reservationListTableView.reloadData()
                            }
                        }
                    }
                })
            }
        }
    }
}

extension ReservationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        reservationUser = chattingUsers[indexPath.row]
    }
}
 
extension ReservationViewController: UITableViewDataSource {
    
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "productInfoCell", for: indexPath) as? ReservationProductInfoTableViewCell else { return UITableViewCell() }
            cell.productTitleLabel.text = productTitle ?? ""
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "reservationUserProfileCell", for: indexPath) as? ReservationUserProfileTableViewCell else { return UITableViewCell() }
            
            cell.addressLabel.text = chattingUsers[indexPath.row].address
            cell.nicknameLabel.text = chattingUsers[indexPath.row].nickname
            cell.timeLabel.text = "마지막 대화 \(chattingUsers[indexPath.row].lastUpdate?.convertTimestamp() ?? "") 전"
            
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
