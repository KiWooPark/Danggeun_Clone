//
//  String+Extention.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/11/06.
//

import Foundation

extension String {
    /// nickname 정규식
    /// - Returns: nickname정규식과 일치한다면 true를 return한다.
    func isValidNickname() -> Bool {
        let nicknameRegEx = "[가-힣A-Za-z0-9]{1,12}"
        
        let nicknamePredicate = NSPredicate(format:"SELF MATCHES %@", nicknameRegEx)
        return nicknamePredicate.evaluate(with: self)
    }
    
    var insertComma: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let result = numberFormatter.string(for: Int(self)) ?? "0"
        return String(result)
    }
}
