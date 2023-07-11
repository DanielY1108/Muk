//
//  SettingViewController.swift
//  Muk
//
//  Created by JINSEOK on 2023/06/26.
//

import UIKit

class SettingViewController: UIViewController {
    
    var viewModel = SettingViewModel()
    var mailManager: MailManager?
    
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
    
    private func mapSettingBinding(with cell: SettingCellViewModel) {
        viewModel.mapType.bind { [weak self] mapType in
            guard let self = self else { return }
            // mapTpye 값이 업데이트 되면, cell에서 만든 바인딩 밸류도 동시에 업데이트 시켜줌
            self.viewModel.updateCellBindingValue(with: cell)
            
            // 노티피케이션 전달 및 유저 디폴트에 저장 (String value)
            NotificationNameIs.mapType.postNotification(with: mapType)
            UserDefaults.standard.setValue(mapType, forKey: MapType.title)
        }
        
        viewModel.mapZoomRange.bind { [weak self] mapZoomRange in
            guard let self = self else { return }
            // mapZoomRange 값이 업데이트 되면, cell에서 만든 바인딩 밸류도 동시에 업데이트 시켜줌
            self.viewModel.updateCellBindingValue(with: cell)
            
            // 노티피케이션 전달 및 유저 디폴트에 저장 (Int value)
            NotificationNameIs.mapZoomRange.postNotification(with: mapZoomRange)
            UserDefaults.standard.setValue(mapZoomRange, forKey: MapZoomRange.title)
        }
    }
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - UITableView DataDase
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NSStringFromClass(SettingHeaderView.self)) as? SettingHeaderView else { return nil }
        let name = viewModel.getTable(at: section).name
        header.setupText(name)
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
        
        let cellViewModel = viewModel.getTableItem(at: indexPath)
        cell.bindingText(with: cellViewModel)
        
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
        
        let cellViewModel = viewModel.getTableItem(at: indexPath)
        mapSettingBinding(with: cellViewModel)
        
        switch cellViewModel.category {
        case .map(.mapType):
            presentAlert(.mapType)
        case .map(.zoomRange):
            presentAlert(.zoomRange)
        case .feedback(.question):
            mailManager = MailManager(viewController: self)
            let emailComponent = EmailComponent()
            mailManager?.presentEmail(with: emailComponent)
        default: break
        }
    }
}

// MARK: - Alert Controller

extension SettingViewController {
    
    private func mapTypeHandler(_ mapTpye: MapType) {
        // 선택된 MapSetting 처리 로직
        print("MapSetting selected:", mapTpye.name)
        
        DispatchQueue.main.async {
            // 바인딩 값 변경 (String)
            self.viewModel.mapType.value = mapTpye.name
            self.tableView.reloadData()
        }
    }
    
    private func mapZoomRangeHandler(_ mapZoomRange: MapZoomRange) {
        // 선택된 MapZoomRange 처리 로직
        print("MapZoomRange selected:", mapZoomRange.name)
        
        DispatchQueue.main.async {
            // 바인딩 값 변경 (Int)
            self.viewModel.mapZoomRange.value = mapZoomRange.rawValue
            self.tableView.reloadData()
        }
    }
    
    private func presentAlert(_ mapCategory: MapSubCategory) {
        switch mapCategory {
        case .mapType:
            let alertController = UIAlertController(title: "\(MapType.title)",
                                                    message: nil,
                                                    preferredStyle: .actionSheet)
            
            for mapTpye in MapType.allCases {
                let action = UIAlertAction(title: mapTpye.name,
                                           style: .default) { [weak self] _ in
                    self?.mapTypeHandler(mapTpye)
                }
                alertController.addAction(action)
            }
            let cancel = UIAlertAction(title: "취소", style: .cancel)
            alertController.addAction(cancel)
            
            self.present(alertController, animated: true)
            
        case .zoomRange:
            let alertController = UIAlertController(title: "\(MapZoomRange.title)",
                                                    message: nil,
                                                    preferredStyle: .actionSheet)
            
            for mapZoomRange in MapZoomRange.allCases {
                let action = UIAlertAction(title: "사용자 중심 \(mapZoomRange.name)",
                                           style: .default) { [weak self] _ in
                    self?.mapZoomRangeHandler(mapZoomRange)
                }
                alertController.addAction(action)
            }
            let cancel = UIAlertAction(title: "취소", style: .cancel)
            alertController.addAction(cancel)
            
            self.present(alertController, animated: true)
        }
    }
}

// MARK: - 맵 관련 옵션 세팅 (Alert 창 관련 값)

enum MapType: CaseIterable {
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

enum MapZoomRange: Int, CaseIterable {
    static var title: String = "사용자 위치 표시 범위 선택"
    
    case twoHundred = 200
    case threeHundred = 300
    case fiveHundred = 500
    case tenHundred = 1000
    case twentyHundred = 2000
    
    // Alert를 띄어 줄 때만 사용 (value로 계산해서 해도 되지만, 코드가 지저분해보임)
    var name: String {
        switch self {
        case .twoHundred:
            return "200m"
        case .threeHundred:
            return "300m"
        case .fiveHundred:
            return "500m"
        case .tenHundred:
            return "1km"
        case .twentyHundred:
            return "2km"
        }
    }
}
