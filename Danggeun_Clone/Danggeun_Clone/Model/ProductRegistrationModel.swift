//
//  ProductRegistrationModel.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/10/11.
//

import Foundation
import FirebaseFirestore

enum ProductStatusType: String {
    case all = "all"
    case trading = "trading"
    case completed = "completed"
    case hidden = "hidden"
}

enum AccessControllerType: String {
    case none
    case productDetailVC
    case addProductVC
    case homeVC
    case baseProfileVC
    case myProduct
    case moreProductsVC
}


struct ProductRegistrationModel {
    var address: String?
    var phoneNumber: String
    var ThumbnailImage: UIImage?
    var imagesURL: [String]
    var productImages: [UIImage]?
    var title: String
    var category: String
    var price: String
    var content: String
    var update: Timestamp
   
    // 안씀
    var isFinished: Bool
    
    var productId: String
    var status: String
    var isReservation: Bool
    
    // 안씀
    var reservationUser: String
    var buyer: String
    var isSellerReview: Bool?
    var isBuyerReview: Bool?
    
    var likeCount: Int?
    var viewCount: Int?
    var isLike: Bool?
    var isHidden: Bool?
    
    // 안씀
    var chattingCount: Int?
    
    init(data: QueryDocumentSnapshot) {
        self.address = data["address"] as? String ?? ""
        self.phoneNumber = data["phoneNumber"] as? String ?? ""
        self.imagesURL = data["imagesURL"] as? [String] ?? []
        self.title = data["title"] as? String ?? ""
        self.category = data["category"] as? String ?? ""
        self.price = data["price"] as? String ?? ""
        self.content = data["contents"] as? String ?? ""
        self.update = data["update"] as! Timestamp
        self.isFinished = data["finished"] as? Bool ?? false
        self.productId = data["productId"] as? String ?? ""
        self.status = data["status"] as? String ?? ""
        self.isReservation = data["reservation"] as? Bool ?? false
        self.reservationUser = data["reservationUser"] as? String ?? ""
        self.buyer = data["buyer"] as? String ?? ""
        self.isSellerReview = data["sellerReview"] as? Bool ?? false
        self.isBuyerReview = data["buyerReview"] as? Bool ?? false
        self.likeCount = data["likeCount"] as? Int ?? 0
        self.viewCount = data["viewCount"] as? Int ?? 0
        self.isLike = data["isLike"] as? Bool ?? false
        self.isHidden = data["isHidden"] as? Bool ?? false
        self.chattingCount = data["chattingCount"] as? Int ?? 0
    }
    
    init(singleData: DocumentSnapshot) {
        self.address = singleData["address"] as? String ?? ""
        self.phoneNumber = singleData["phoneNumber"] as? String ?? ""
        self.imagesURL = singleData["imagesURL"] as? [String] ?? []
        self.title = singleData["title"] as? String ?? ""
        self.category = singleData["category"] as? String ?? ""
        self.price = singleData["price"] as? String ?? ""
        self.content = singleData["contents"] as? String ?? ""
        self.update = singleData["update"] as! Timestamp
        self.isFinished = singleData["finished"] as? Bool ?? false
        self.productId = singleData["productId"] as? String ?? ""
        self.status = singleData["status"] as? String ?? ""
        self.isReservation = singleData["reservation"] as? Bool ?? false
        self.reservationUser = singleData["reservationUser"] as? String ?? ""
        self.buyer = singleData["buyer"] as? String ?? ""
        self.isSellerReview = singleData["sellerReview"] as? Bool ?? false
        self.isBuyerReview = singleData["buyerReview"] as? Bool ?? false
        self.likeCount = singleData["likeCount"] as? Int ?? 0
        self.viewCount = singleData["viewCount"] as? Int ?? 0
        self.isLike = singleData["isLike"] as? Bool ?? false
        self.isHidden = singleData["isHidden"] as? Bool ?? false
        self.chattingCount = singleData["chattingCount"] as? Int ?? 0
    }
}
