//
//  Timestamp+Extension.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/11/15.
//

import Foundation
import FirebaseFirestore

extension Timestamp {
    func convertTimestamp() -> String {
        let formatter = DateComponentsFormatter()
        // 시간 단위 설정
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        // 시간 단위를 몇개를 나타낼 것인가
        formatter.maximumUnitCount = 1
        
        // 단위의 가장 앞글자 약어(s, m, h, d, w등)으로 설정
        formatter.unitsStyle = .abbreviated
        
        // 한글로 변환
        var calender = Calendar.current
        calender.locale = Locale(identifier: "Ko")
        formatter.calendar = calender
        
        return formatter.string(from: self.dateValue(), to: Date()) ?? ""
    }
}
