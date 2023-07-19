//
//  SettingViewModel.swift
//  Muk
//
//  Created by JINSEOK on 2023/06/28.
//

import UIKit

struct TableSection {
    let name: String
    let rows: [SettingCellViewModel]
}

class SettingViewModel {
    
    private(set) var dataSource: [TableSection]!
    
    // 초기 저장값을 시작 시, 로드해서 표시
    private(set) var mapType: Observable<String> = Observable("표준")
    private(set) var mapZoomRange: Observable<Int> = Observable(500)
    
    private var stringMapZoomRange: String {
        return calcAndStringConvert(for: mapZoomRange.value)
    }
    
    init() {
        loadUserDefault()
        setupDataSource()
    }
    
    private func setupDataSource() {
        
        let mapRows: [SettingCellViewModel] = [
            SettingCellViewModel(category: .map(.mapType), option: mapType.value),
            SettingCellViewModel(category: .map(.zoomRange), option: stringMapZoomRange)
        ]
        
        let feedbackRows: [SettingCellViewModel] = [
            SettingCellViewModel(category: .feedback(.appReview)),
            SettingCellViewModel(category: .feedback(.question))
        ]
        
        let infoRows: [SettingCellViewModel] = [
            SettingCellViewModel(category: .appInfo(.help)),
            SettingCellViewModel(category: .appInfo(.tutorial)),
            SettingCellViewModel(category: .appInfo(.privacyPolicy)),
            SettingCellViewModel(category: .appInfo(.termsAndCondtions)),
            SettingCellViewModel(category: .appInfo(.version), option: "1.0")
        ]
        
        dataSource = [
            TableSection(name: "지도", rows: mapRows),
            TableSection(name: "피드백", rows: feedbackRows),
            TableSection(name: "앱 정보", rows: infoRows)
        ]
    }
    
    // 각 섹션
    func getTable(at section: Int) -> TableSection {
        return dataSource[section]
    }
    
    // 각 섹션의 아이템
    func getTableItem(at indexPath: IndexPath) -> SettingCellViewModel {
        return dataSource[indexPath.section].rows[indexPath.row]
    }
    
    // 섹션의 갯수
    func numberOfSections() -> Int {
        return dataSource.count
    }
    
    // 셀(아이템)의 갯수
    func numberOfRows(in section: Int) -> Int {
        return dataSource[section].rows.count
    }
    
    // 셀(SettingCellViewModel)과 SettingViewModel을 바인딩
    func updateCellBindingValue(with cell: SettingCellViewModel) {
        switch cell.category {
        case .map(.mapType):
            cell.option.value = mapType.value
        case .map(.zoomRange):
            cell.option.value = stringMapZoomRange
        default: break
        }
    }
    
    // ZoomRange값을 String 값으로 변환 (mapview에서는 Int값이 사용되고, 여기선 String 값이 필요)
    private func calcAndStringConvert(for zoomRange: Int) -> String {
        if zoomRange < 1000 {
            return "\(zoomRange)m"
        } else {
            return "\(zoomRange/1000)km"
        }
    }
}

// MARK: - UserDefault 로드 작업 (초기값 작업)

extension SettingViewModel {
    
    private func loadUserDefault() {
        // Map Type
        if let mapTypeValue = UserDefaults.standard.value(forKey: MapType.title) as? String {
            self.mapType.value = mapTypeValue
        }
        
        // Zoom Range
        if let zoomRangeValue = UserDefaults.standard.value(forKey: MapZoomRange.title) as? Int {
            self.mapZoomRange.value = zoomRangeValue
        }
    }
}
