//
//  SettingViewController.swift
//  Muk
//
//  Created by JINSEOK on 2023/06/26.
//

import UIKit

class SettingViewController: UIViewController {
    
    var viewModel = SettingViewModel()
    
    private lazy var tableView: UITableView = {
        // 테이블뷰의 기본 스타일은 plain인데, 헤더가 고정되어 보여진다. grouped를 사용하면 같이 움직임
        let table = UITableView(frame: view.frame, style: .grouped)
        table.separatorStyle = .none
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = HexCode.background.color
        table.register(SettingCell.self, forCellReuseIdentifier: NSStringFromClass(SettingCell.self))
        table.register(SettingHeaderView.self, forHeaderFooterViewReuseIdentifier: NSStringFromClass(SettingHeaderView.self))
        table.register(SettingFooterView.self, forHeaderFooterViewReuseIdentifier: NSStringFromClass(SettingFooterView.self))
        return table
    }()
 
    // MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    private func setupUI() {
        let titleLabel = UIFactory.createNavigationTitleLabel("Setting")
        navigationItem.titleView = titleLabel
        
        view.addSubview(tableView)
    }
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {

    // MARK: - UITableView DataDase
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NSStringFromClass(SettingHeaderView.self)) as? SettingHeaderView else { return nil }
        header.name.value = viewModel.getTable(section).name
        return header
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: NSStringFromClass(SettingFooterView.self)) as? SettingFooterView else { return nil }
        return footer
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(SettingCell.self),
                                                       for: indexPath) as? SettingCell else {
            fatalError("Failed Load Cell")
        }
     
        cell.name.value = viewModel.getTableItem(forRowAt: indexPath).name
        if let option = viewModel.getTableItem(forRowAt: indexPath).option {
            cell.option.value = option
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    // MARK: - UITableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedCell = viewModel.getTableItem(forRowAt: indexPath)
        
        switch selectedCell.name {
        case SettingTitle.MapType.rawValue:
            showAlert(.mapType)
        case SettingTitle.ZoomRange.rawValue:
            showAlert(.zoomRange)
        default: break
        }
    }
}

// MARK: - Alert Controller

extension SettingViewController {
    
    private func mapTypeHandler(_ mapTpye: MapType) {
        // 선택된 MapSetting 처리 로직
        print("MapSetting selected:", mapTpye)
    }
    
    private func mapZoomRangeHandler(_ mapZoomRange: MapZoomRange) {
        // 선택된 MapZoomRange 처리 로직
        print("MapZoomRange selected:", mapZoomRange)
    }
    
    private func showAlert(_ mapSetting: MapSetting) {
        switch mapSetting {
        case .mapType:
            self.present(makeAlert(mapSetting), animated: true)
        case .zoomRange:
            self.present(makeAlert(mapSetting), animated: true)
        }
    }
    
    private func makeAlert(_ mapSetting: MapSetting) -> UIAlertController {
        switch mapSetting {
        case .mapType:
            let alert = UIAlertController(title: "\(MapType.title)",
                                          message: nil,
                                          preferredStyle: .actionSheet)
    
            for mapTpye in MapType.allCases {
                let action = UIAlertAction(title: mapTpye.name,
                                           style: .default) { [weak self] _ in
                    self?.mapTypeHandler(mapTpye)
                }
                alert.addAction(action)
            }
            let cancel = UIAlertAction(title: "취소", style: .cancel)
            alert.addAction(cancel)
    
            return alert
    
        case .zoomRange:
            let alert = UIAlertController(title: "\(MapZoomRange.title)",
                                          message: nil,
                                          preferredStyle: .actionSheet)
    
            for zoomRange in MapZoomRange.allCases {
                let action = UIAlertAction(title: zoomRange.name,
                                           style: .default) { [weak self] _ in
                    self?.mapZoomRangeHandler(zoomRange)
                }
                alert.addAction(action)
            }
            let cancel = UIAlertAction(title: "취소", style: .cancel)
            alert.addAction(cancel)
    
            return alert
        }
    }
}

// MARK: - Helper

fileprivate enum MapSetting {
    case mapType
    case zoomRange
}

fileprivate enum MapType: CaseIterable {
    static var title: String = "지도 종류 선택"
    
    case standard
    case satellite
    case hybrid
    
    var name: String {
        switch self {
        case .standard:
            return "표준"
        case .satellite:
            return "위성"
        case .hybrid:
            return "하이브리드"
        }
    }
}

fileprivate enum MapZoomRange: CaseIterable {
    static var title: String = "사용자 위치 표시 범위 선택"
    
    case twoHundred
    case threeHundred
    case fiveHundred
    case tenHundred
    case twentyHundred
    
    var name: String {
        switch self {
        case .twoHundred:
            return "사용자 중심 200m"
        case .threeHundred:
            return "사용자 중심 300m"
        case .fiveHundred:
            return "사용자 중심 500m"
        case .tenHundred:
            return "사용자 중심 1km"
        case .twentyHundred:
            return "사용자 중심 2km"
        }
    }
}
