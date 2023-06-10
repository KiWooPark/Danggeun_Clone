//
//  ChatListViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/06/24.
//

import UIKit
import FirebaseFirestore

struct ChatRoomInfoModel {
    var productId: String
    var chatRoomId: String
    var profileImage: String?
    var title: String
    var region: String
    var time: NSDate
    var content: String
    var productImage: String?
    var pushToken: String
}

class ChatListViewController: UIViewController {
    
    @IBOutlet var chatListTableView: UITableView!
    
    let db = Firestore.firestore()

    var chatRoomList = [ChatRoomInfoModel]()
    var loginUserInfo = UserModel.getUserData()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("뷰 갱신")
        
        fetchDB() {
            self.chatListTableView.reloadData()
        }
    }
    
    func fetchDB(completion: @escaping () -> ()) {
        
        // 채팅방에 내가 속해 있는지 체크
        // 속해있다면 상대방 프로필이미지, 닉네임, 지역 보여주기
        // 게시글 상품 이미지가 있다면 보여주기
        
        db.collection("채팅").whereField("users", arrayContains: loginUserInfo?.phoneNumber ?? "").addSnapshotListener { snapShot, error in
            if let error = error {
                print("채팅방 정보 가져오기 실패 = \(error)")
            }
            
            guard let chatRoom = snapShot?.documents else { return }
            
           
            self.chatRoomList.removeAll()
            
            print(chatRoom)
            
            for field in chatRoom {
                if field.data()["buyer"] as? String ?? "" == self.loginUserInfo?.phoneNumber ?? "" {
                    let chatRoomData = ChatRoomInfoModel(productId: field.data()["productId"] as? String ?? "",
                                                         chatRoomId: field.data()["chatRoomId"] as? String ?? "",
                                                         profileImage: field.data()["sellerProfileImage"] as? String ?? "",
                                                         title: field.data()["sellerNickName"] as? String ?? "",
                                                         region: field.data()["sellerAddress"] as? String ?? "",
                                                         time: NSDate(timeIntervalSince1970: TimeInterval((field.data()["lastUpdate"] as? Timestamp)?.seconds ?? Int64())),
                                                         content: field.data()["lastMessage"] as? String ?? "",
                                                         productImage: field.data()["sellerProfileImage"] as? String ?? "",
                                                         pushToken: field.data()["sellerPushToken"] as? String ?? "")
                    self.chatRoomList.append(chatRoomData)
                    completion()
                } else {
                    let chatRoomData = ChatRoomInfoModel(productId: field.data()["productId"] as? String ?? "",
                                                         chatRoomId: field.data()["chatRoomId"] as? String ?? "",
                                                         profileImage: field.data()["buyerProfileImage"] as? String ?? "",
                                                         title: field.data()["buyerNickName"] as? String ?? "",
                                                         region: field.data()["buyerAddress"] as? String ?? "",
                                                         time: NSDate(timeIntervalSince1970: TimeInterval((field.data()["lastUpdate"] as? Timestamp)?.seconds ?? Int64())),
                                                         content: field.data()["lastMessage"] as? String ?? "",
                                                         productImage: field.data()["buyerProfileImage"] as? String ?? "",
                                                         pushToken: field.data()["buyerPushToken"] as? String ?? "")
                    self.chatRoomList.append(chatRoomData)
                    completion()
                }
            }
        }
    }
}


extension ChatListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatRoomList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ChatListTableViewCell else { return UITableViewCell() }
        cell.profileImageView.kf.setImage(with: URL(string: chatRoomList[indexPath.row].profileImage ?? ""),placeholder: UIImage(named: "user"))
        cell.titleLabel.text = chatRoomList[indexPath.row].title
        cell.regionLabel.text = chatRoomList[indexPath.row].region
        cell.timeLabel.text = chatRoomList[indexPath.row].time.convertTime()
        cell.contentLabel.text = chatRoomList[indexPath.row].content
        return cell
    }
}

extension ChatListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Chatting", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "chatRoom") as? ChatRoomViewController else { return }
        vc.viewType = "chatRoomList"
        vc.chatRoomData = chatRoomList[indexPath.row]
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
