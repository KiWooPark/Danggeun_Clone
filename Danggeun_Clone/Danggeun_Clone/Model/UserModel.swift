//
//  UserModel.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/10/09.
//

import Foundation
import FirebaseFirestore

/// 유저 모델
struct UserModel: Codable {
    var selectedAddress: String
    var address1: String
    var authAddress1: Bool
    var address2: String?
    var authAddress2: Bool
    var nickname: String?
    var phoneNumber: String?
    var profileImageUrl: String?
    var productsCount: [String: Int]?

    init(data: DocumentSnapshot) {
        self.selectedAddress = data["selectedAddress"] as? String ?? ""
        self.address1 = data["address1"] as? String ?? ""
        self.authAddress1 = data["authAddress1"] as? Bool ?? false
        self.address2 = data["address2"] as? String ?? ""
        self.authAddress2 = data["authAddress2"] as? Bool ?? false
        self.nickname = data["nickname"] as? String ?? ""
        self.phoneNumber = data["phoneNumber"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
        self.productsCount = data["productsCount"] as? [String: Int] ?? [:]
    }
    
    init(data: [String: Any]) {
        self.selectedAddress = data["selectedAddress"] as? String ?? ""
        self.address1 = data["address1"] as? String ?? ""
        self.authAddress1 = data["authAddress1"] as? Bool ?? false
        self.address2 = data["address2"] as? String ?? ""
        self.authAddress2 = data["authAddress2"] as? Bool ?? false
        self.nickname = data["nickname"] as? String ?? ""
        self.phoneNumber = data["phoneNumber"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
        self.productsCount = data["productsCount"] as? [String: Int] ?? [:]
    }
    
    init(address: String, phoneNumber: String?) {
        self.selectedAddress = address
        self.address1 = address
        self.authAddress1 = false
        self.address2 = nil
        self.authAddress2 = false
        self.nickname = nil
        self.phoneNumber = phoneNumber
        self.profileImageUrl = nil
        self.productsCount = nil
    }

    /// 유저 디폴트에 저장된 유저 데이터 가져오기
    /// - Returns: 유저 데이터
    static func getUserData() -> UserModel? {
        var result: UserModel?
        
        if let userData = UserDefaults.standard.object(forKey: "LoginUser") as? Data {
            let decoder = JSONDecoder()
            do {
                result = try decoder.decode(UserModel.self, from: userData)
            } catch {
                print("유저정보 가져오기 실패")
            }
        }
        return result
    }

    /// 유저 디폴트에 유저 데이터 저장하기
    /// - Parameter userData: 저장할 유저 데이터
    static func saveUserData(userData: UserModel?) {
        
        do {
            let encoder = JSONEncoder()
            let userData = try encoder.encode(userData)
            UserDefaults.standard.set(userData, forKey: "LoginUser")
        } catch {
            print("유저정보 저장 실패", error)
        }
    }
}

