//
//  SettingViewModel.swift
//  Muk
//
//  Created by JINSEOK on 2023/06/28.
//

import UIKit

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
            TableItem(name: "지도 종류", option: "표준"),
            TableItem(name: "지도 표시 범위", option: "500m")
        ]
        
        feedbackRows = [
            TableItem(name: "앱 리뷰"),
            TableItem(name: "문의사항")
        ]
        
        infoRows = [
            TableItem(name: "도움말"),
            TableItem(name: "개인정보 정책"),
            TableItem(name: "이용약관"),
            TableItem(name: "버전", option: "1.0")
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
