//
//  SettingCategory.swift
//  Muk
//
//  Created by JINSEOK on 2023/07/05.
//

import Foundation

// MARK: - 기본 타이틀 설정

enum SettingCategory {
    case map(MapSubCategory)
    case feedback(FeedbackSubCategory)
    case appInfo(AppInfoSubCategory)
    
    var title: String {
        switch self {
        case .map(let mapSubCategory):
            return mapSubCategory.rawValue
        case .feedback(let feedbackSubCategory):
            return feedbackSubCategory.rawValue
        case .appInfo(let appInfoSubCategory):
            return appInfoSubCategory.rawValue
        }
    }
}

enum MapSubCategory: String {
    case mapType = "지도 종류"
    case zoomRange = "사용자 위치 표시 범위"
}

enum FeedbackSubCategory: String {
    case appReview = "앱 리뷰"
    case question = "문의 사항"
}

enum AppInfoSubCategory: String {
    case help = "도움말"
    case privacyPolicy = "개인정보 정책"
    case termsAndCondtions = "이용약관"
    case version = "버전"
}
