//
//  NSData+Extention.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/11/07.
//

import Foundation
import FirebaseFirestore

extension NSDate {
    
    func convertDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        formatter.locale = Locale(identifier: "ko_kr")
        return formatter.string(from: self as Date)
    }
    
    func convertTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ko_kr")
        return formatter.string(from: self as Date)
    }
}
