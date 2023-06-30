//
//  SettingViewModel.swift
//  Muk
//
//  Created by JINSEOK on 2023/06/28.
//

import UIKit

enum SettingTitle: String {
    case MapType = "지도 종류"
    case ZoomRange = "사용자 위치 표시 범위"
    case Review = "앱 리뷰"
    case Question = "문의사항"
    case Help = "도움말"
    case PrivacyPolicy = "개인정보 정책"
    case TermsAndConditions = "이용약관"
    case Version = "버전"
}

class SettingViewModel {
    
    private var dataSource: [TableSection]!
    private var mapRows: [TableItem]!
    private var feedbackRows: [TableItem]!
    private var infoRows: [TableItem]!
    
    init() {
        setupDataSource()
    }
    
    private func setupDataSource() {
        mapRows = [
            TableItem(name: SettingTitle.MapType.rawValue, option: "표준"),
            TableItem(name: SettingTitle.ZoomRange.rawValue, option: "500m")
        ]
        
        feedbackRows = [
            TableItem(name: SettingTitle.Review.rawValue),
            TableItem(name: SettingTitle.Question.rawValue)
        ]
        
        infoRows = [
            TableItem(name: SettingTitle.Help.rawValue),
            TableItem(name: SettingTitle.PrivacyPolicy.rawValue),
            TableItem(name: SettingTitle.TermsAndConditions.rawValue),
            TableItem(name: SettingTitle.Version.rawValue, option: "1.0")
        ]
        
        dataSource = [
            TableSection(name: "지도", rows: mapRows),
            TableSection(name: "피드백", rows: feedbackRows),
            TableSection(name: "앱 정보", rows: infoRows)
        ]
    }
    
    func getTable(_ section: Int) -> TableSection {
        return dataSource[section]
    }
    
    func getTableItem(forRowAt indexPath: IndexPath) -> TableItem {
        return dataSource[indexPath.section].rows[indexPath.row]
    }
        
    func numberOfSections() -> Int {
        return dataSource.count
    }
    
    func numberOfRows(in section: Int) -> Int {
        return dataSource[section].rows.count
    }
}

struct TableSection {
    let name: String
    let rows: [TableItem]
}

struct TableItem {
    let name: String
    var option: String?
}
