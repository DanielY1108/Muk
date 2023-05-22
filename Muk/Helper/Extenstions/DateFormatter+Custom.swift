//
//  DateFormatter.swift
//  Muk
//
//  Created by JINSEOK on 2023/05/10.
//

import Foundation

extension DateFormatter {
    
    // 날짜 형식 변환
    static func custom(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        
        return formatter.string(from: date)
    }
}
