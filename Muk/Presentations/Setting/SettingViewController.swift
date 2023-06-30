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

// MARK: - UITableView

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {

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
}


