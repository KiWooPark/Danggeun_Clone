//
//  ChatRoomViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/06/23.
//

import UIKit
import FirebaseFirestore
import SnapKit

struct MessagesModel {
    var user: String
    var message: String
    var update: NSDate
}

struct PushMessageModel: Codable {
    let to: String
    let notification: Notification
    
    struct Notification: Codable {
        let title: String
        let body: String
    }
}

class ChatRoomViewController: UIViewController {
    
    @IBOutlet var messageTextView: UITextView!
    @IBOutlet var messageTableView: UITableView!

    let db = Firestore.firestore()
    var messages = [MessagesModel]()
    
    // 게시물id와 판매자 정보
    var viewType: String?
    
    // 디테일뷰에서 전달받은 데이터
    var productId: String?
    //var chatRoomId: String?
    
    // 채팅목록에서 전달받은 데이터
    var chatRoomData: ChatRoomInfoModel?
    
    var productUserData: UserModel?
    let loginUserData = UserModel.getUserData()
    
    @IBOutlet var messageTableViewHeight: NSLayoutConstraint!
    
    @IBOutlet var bottomViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var bottomViewContainerViewHeight: NSLayoutConstraint!
    
    // 채팅방 유무 체크
    var isChattingRoom = false
    
    // 키보드 상태 체크
    var isUpKeyboard = false
    
    // 부가기능뷰 상태 체크
    var isUpBottomView = false
    
    // 키보드 높이
    var keyboardHeight = 0.0
    var safeAreaInsetBottom: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.title = productUserData?.nickname ?? ""
        safeAreaInsetBottom = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0.0
        
//        let tapHideKeyboard = UITapGestureRecognizer(target: self, action: #selector(tapMessageTableView(_:)))
//        tapHideKeyboard.cancelsTouchesInView = false
//        tapHideKeyboard.numberOfTapsRequired = 1
//        tapHideKeyboard.numberOfTouchesRequired = 1
//        self.view.addGestureRecognizer(tapHideKeyboard)
        
        let messageTableViewTap = UITapGestureRecognizer(target: self, action: #selector(tapMessageTableView(_:)))
        messageTableView.addGestureRecognizer(messageTableViewTap)
        
        //let messageTextViewTap = UITapGestureRecognizer(target: self, action: #selector(tapMessageTextView(_:)))
        //messageTextView.addGestureRecognizer(messageTextViewTap)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.addKeyboardNotifications()
        
        if viewType ?? "" == "detail" {
            checkChatRoom()
        } else {
            isChattingRoom = true
            
            getMessages(document: chatRoomData?.chatRoomId ?? "") {
                self.messageTableView.reloadData()
                DispatchQueue.main.async {
                    let index = IndexPath(row: self.messages.count-1, section: 0)
                    self.messageTableView.scrollToRow(at: index, at: .bottom, animated: true)
                    self.messageTextView.text = ""
                }
            }
        }
        
        
        
        // 키보드 높이값 가져오기
        if keyboardHeight == 0.0 {
            let dummyTextField = UITextView()
            UIApplication.shared.windows.first?.addSubview(dummyTextField)
            dummyTextField.becomeFirstResponder()
            dummyTextField.resignFirstResponder()
            dummyTextField.removeFromSuperview()
        }
        
        
        bottomViewBottomConstraint.constant = keyboardHeight - safeAreaInsetBottom
        bottomViewContainerViewHeight.constant = keyboardHeight
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.removeKeyboardNotifications()
        
//        let productUser = productUserData?.phone ?? ""
//        let productUUID = chatRoomData ?? ""
//        let chatRoomId = productUser + loginUserData.phone + productUUID
        
        // 채팅방에서 뒤로 안가고 백그라운드로 갔을때 저장하는것도 구현 필요
        if viewType == "detail" {
            //            db.collection("채팅").document(chatRoomId).updateData(
            //                ["lastMessage": messages.last?.message as? String ?? "",
            //                 "lastUpdate": messages.last?.update ?? Date()])
        } else {
            
        }
    }
    
    //3
    @IBAction func sendMessage(_ sender: Any) {
        
        guard let message = messageTextView.text else { return }
        guard let loginUser = loginUserData else { return }

        
        if messageTextView.text != "" {
            if viewType == "detail" {
                let productUser = productUserData?.phoneNumber ?? ""
                let productUUID = productId ?? ""
                let chatRoomId = productUser + (loginUserData?.phoneNumber ?? "") + productUUID

                // 채팅방이 없으면

                // 7 / 8일 푸시토큰값 저장하기
                // 푸시토큰값 변경됬을때 어떻게 해야할지
                // 주소, 프로필이미지, 닉네임 변경시 어디서 업데이트 할지
                if !isChattingRoom {
                    db.collection("채팅").document(chatRoomId).setData([
                        "seller": productUser,
                        "sellerNickName" : productUserData?.nickname ?? "",
                        "sellerProfileImage": productUserData?.profileImageUrl ?? "",
                        "sellerAddress": productUserData?.selectedAddress ?? "",
                        "sellerPushToken": productUserData?.pushToken ?? "",
                        "buyer": loginUser.phoneNumber,
                        "buyerNickName": loginUser.nickname,
                        "buyerProfileImage": loginUser.profileImageUrl,
                        "buyerAddress": loginUser.selectedAddress,
                        "buyerPushToken": loginUser.pushToken,
                        "lastUpdate" : Date(),
                        "lastMessage": "",
                        "chatRoomId": chatRoomId,
                        "productId": productUUID,
                        "users": [productUser,loginUser.phoneNumber]
                    ]) { error in
                        if let error = error {
                            print("채팅방 생성 실패 = \(error)")
                        }
                        self.db.collection("채팅").document(chatRoomId).collection("대화내용").document().setData([
                            "user" : self.loginUserData?.phoneNumber ?? "",
                            "message" : message,
                            "update" : Date()
                        ]) { error in
                            if let error = error {
                                print("채팅방 생성 완료 후 메시지 저장 실패 = \(error)")
                            }
                            
                            // 게시글에 채팅 카운트 올리기
                            self.db.collection("게시글").document(productUUID).getDocument { snapShot, error in
                                if let error = error {
                                    print("게시글 데이터 가져오기 실패", error)
                                }
                                
                                if let chattingCount = snapShot?.data()?["chattingCount"] as? Int {
                                    self.db.collection("게시글").document(productUUID).updateData(["chattingCount": chattingCount + 1]) { error in
                                        if let error = error {
                                            print("채팅 카운트 업데이트 실패", error)
                                        }
                                        
                                        // 보내는 사람 = 로그인한 사람, 받는사람 = 게시물 올린사람
                                        self.sendPushMessage(title: self.loginUserData?.nickname ?? "", body: message, token: self.chatRoomData?.pushToken ?? "")
                                        self.isChattingRoom = true
                                    }
                                } else {
                                    self.db.collection("게시글").document(productUUID).updateData(["chattingCount": 1]) { error in
                                        if let error = error {
                                            print("채팅 카운트 업데이트 실패", error)
                                        }
                                        
                                        // 보내는 사람 = 로그인한 사람, 받는사람 = 게시물 올린사람
                                        self.sendPushMessage(title: self.loginUserData?.nickname ?? "", body: message, token: self.chatRoomData?.pushToken ?? "")
                                        self.isChattingRoom = true
                                    }
                                }
                            }
                        }
                    }
                } else {
                    db.collection("채팅").document(chatRoomId).collection("대화내용").addDocument(data: [
                        "user": loginUserData?.phoneNumber ?? "",
                        "message": message,
                        "update": Date()
                    ])
                    sendPushMessage(title: loginUserData?.nickname ?? "", body: message, token: self.chatRoomData?.pushToken ?? "")
                }

                self.getMessages(document: chatRoomId) {
                    self.messageTableView.reloadData()
                    DispatchQueue.main.async {
                        if !self.messages.isEmpty {
                            let index = IndexPath(row: self.messages.count-1, section: 0)
                            self.messageTableView.scrollToRow(at: index, at: .bottom, animated: true)
                            self.messageTextView.text = ""
                        }
                    }
                }
            } else {
                db.collection("채팅").document(self.chatRoomData?.chatRoomId ?? "").collection("대화내용").addDocument(data: [
                    "user": loginUserData?.phoneNumber ?? "",
                    "message": message,
                    "update": Date()
                ])

                sendPushMessage(title: loginUserData?.nickname ?? "", body: message, token: self.chatRoomData?.pushToken ?? "")
                getMessages(document: self.chatRoomData?.chatRoomId ?? "") {
                    self.messageTableView.reloadData()
                    DispatchQueue.main.async {
                        let index = IndexPath(row: self.messages.count-1, section: 0)
                        self.messageTableView.scrollToRow(at: index, at: .bottom, animated: true)
                        self.messageTextView.text = ""
                    }
                }
            }
        }
    }
    
    func sendPushMessage(title: String, body: String, token: String) {
        let serverKey = "key=AAAAt368Nk4:APA91bHtkTwPhSNS_qXfmSdjqvLIRP0r8otDIRHItO0DYQ-fBcwzgngegB8VfiRQKaRenSKGqkLw85QiLpLiv5R_hFIBBOF3mfI8dTxMzlO1-4d5W1CRpBWwLbxpidpfVvMzgwH8cMMd"
        guard let url = URL(string: "https://fcm.googleapis.com/fcm/send") else { return }
        let body = PushMessageModel.Notification(title: title, body: body)
        let pushData = PushMessageModel(to: token, notification: body)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let encodeData = try? encoder.encode(pushData)
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = encodeData
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue(serverKey, forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("푸시 메시지 보내기 실패 : \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { return }
            
            guard let responseData = data else { return }
            let jsonString = String(data: responseData, encoding: .utf8)
        }
        task.resume()
    }
    
    //1
    func checkChatRoom() {
        db.collection("채팅").getDocuments { snap, error in
            
            guard let chatRoomTitle = snap else { return }
            
            // 게시물 UUID 필터링
            let filterUUID = chatRoomTitle.documents.filter({$0.documentID.contains(self.productId ?? "")})
            
            // 필터링된 게시글중 기기에 로그인된 유저가 속해있는 게시글 필터링
            let filterUser = filterUUID.filter({$0.documentID.contains(UserModel.getUserData()?.phoneNumber ?? "")}).first
        
            self.isChattingRoom = filterUser == nil ? false : true
            
            if self.isChattingRoom {
                self.getMessages(document: filterUser?.documentID ?? "") {
                    self.messageTableView.reloadData()
                }
            }
        }
    }
    
    //2
    func getMessages(document: String, completion: @escaping () -> ()) {
        db.collection("채팅").document(document).collection("대화내용").order(by: "update").addSnapshotListener { documentSnapShot, error in
            if let error = error {
                print("채팅정보 가져오기 실패 = \(error)")
            }
            guard let data = documentSnapShot else { return }
            
            self.messages.removeAll()
            
            for document in data.documents {
                let message = MessagesModel(user: document.data()["user"] as? String ?? "",
                                       message: document.data()["message"] as? String ?? "",
                                       update: NSDate(timeIntervalSince1970: TimeInterval((document["update"] as? Timestamp)?.seconds ?? Int64())))
                
                self.messages.append(message)
            }
            
            if let firstData = self.messages.first {
                self.messages.insert(firstData, at: 0)
            }
            
            // 마지막 메시지 업데이트
            self.db.collection("채팅").document(document).updateData(
                ["lastMessage": self.messages.last?.message as? String ?? "",
                 "lastUpdate": self.messages.last?.update ?? Date()])
            
            completion()
        }
    }
    
    func checkMyProduct() {
        
    }
    
    // 바텀뷰가 올라와 있는 상태에서 텍스트필드 누르면 키보드 올라와야함
    func upDownKeyboard() {
    
        // 바텀뷰가 올라온 상태일때
        if isUpBottomView {
            messageTableViewHeight.constant -= keyboardHeight
            bottomViewBottomConstraint.constant -= keyboardHeight
        } else { // 바텀뷰가 내려간 상태일때
            messageTableViewHeight.constant += keyboardHeight
            bottomViewBottomConstraint.constant += keyboardHeight
        }
        
        let bottomOffset = messageTableView.contentSize.height - messageTableView.bounds.size.height
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0) {

            if !self.isUpBottomView {
                self.messageTableView.setContentOffset(CGPoint(x: 0, y: bottomOffset - self.keyboardHeight), animated: false)
            } else {
                self.messageTableView.setContentOffset(CGPoint(x: 0, y: bottomOffset + self.keyboardHeight), animated: false)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func testButton(_ sender: Any) {
        print("테스트",isUpBottomView, isUpKeyboard)
    }
    
    
    @IBAction func otherFunction(_ sender: Any) {
        // 키보드가 올라와 있는 상태에서는 키보드만 내려줌
        if isUpKeyboard {
            messageTextView.endEditing(true)
        } else { // 키보드가 올라와 있지 않은 경우에는 바텀뷰를 올렸다 내렸다 해줘야함
            isUpBottomView = isUpBottomView ? false : true
            upDownKeyboard()
        }
    }

    @objc func tapMessageTableView(_ sender: UITapGestureRecognizer) {
        // 바텀뷰, 키보드가 둘다 아래에 있는 경우가 아닐때만
        if !(!isUpKeyboard && !isUpBottomView) {
            // 키보드, 바텀뷰 둘다 다 내림
            isUpBottomView = false
            messageTextView.endEditing(true)
            upDownKeyboard()
        }
    }
    
    func addKeyboardNotifications(){
        // 키보드가 나타날 때 앱에 알리고 keyboardWillShow() 메소드를 실행하는 Observer를 추가한다.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification , object: nil)
        // 키보드가 사라질 때 앱에 알리고 keyboardWillHide() 메소드를 실행하는 Observer를 추가한다.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    func removeKeyboardNotifications(){
        // 키보드가 나타날 때 앱에게 알리는 Observer를 제거한다.
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification , object: nil)
        // 키보드가 사라질 때 앱에게 알리는 Observer를 제거한다.
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
   
    
    var isUpFirstKeyboard = false
    // 키보드가 나타나는 UIResponder.keyboardWillShowNotification 알림 수신
    @objc func keyboardWillShow(_ noti: NSNotification) {
        
        if let keyboardFrame: NSValue = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
     
            if keyboardHeight == 0.0 {
                keyboardHeight = keyboardRectangle.height
                // 맨처음 키보드 높이 값 가져온 후 상태값 true로 변경
                isUpFirstKeyboard = true
            } else {
                if isUpKeyboard {
                    return
                } else {
                    // 키보드, 바텀뷰가 다 아래에 있을 경우에만
                    if !isUpKeyboard && !isUpBottomView {
                        isUpKeyboard = true
                        isUpBottomView = true
                        upDownKeyboard()
                    }
                    // 키보드가 올라온상태면 무조건 바텀뷰도 올라와야 함
                    isUpKeyboard = true
                    isUpBottomView = true
                }
            }
        }
    }
    
    // 키보드가 사라지는 UIResponder.keyboardWillHideNotification 알림 수신
    @objc func keyboardWillHide(_ noti: NSNotification) {
        
        if let keyboardFrame: NSValue = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            
            // 맨처음 키보드 높이 값 가져온 후 상태값 false로 변경
            if isUpFirstKeyboard {
                isUpFirstKeyboard = false
                return
            }
            isUpKeyboard = false
        }
    }
}

extension ChatRoomViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if !messages.isEmpty {
            if indexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "startDateCell", for: indexPath) as?
                        StartDateTableViewCell else { return UITableViewCell() }
                cell.dateLabel.text = messages[indexPath.row].update.convertDate()
                return cell
            } else if messages[indexPath.row].user == loginUserData?.phoneNumber ?? "" {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "rightUserCell", for: indexPath) as? RightUserTableViewCell else { return UITableViewCell() }
                cell.messageLabel.text = messages[indexPath.row].message
                cell.timeLabel.text = messages[indexPath.row].update.convertTime()
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "leftUserCell", for: indexPath) as? leftUserTableViewCell else { return UITableViewCell() }
                cell.messageLabel.text = messages[indexPath.row].message
                cell.timeLabel.text = messages[indexPath.row].update.convertTime()
                cell.profileImageView.kf.setImage(with: URL(string: chatRoomData?.profileImage ?? ""),placeholder: UIImage(named: "user"))
                return cell
            }
        }
        return UITableViewCell()
    }
}

