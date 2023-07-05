//
//  SettingCell.swift
//  Muk
//
//  Created by JINSEOK on 2023/06/28.
//

import UIKit

class SettingCell: UITableViewCell {
    
    private var config: UIListContentConfiguration!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = HexCode.background.color
        
        config = self.defaultContentConfiguration()
        config.prefersSideBySideTextAndSecondaryText = true
        config.textProperties.font = .systemFont(ofSize: 15, weight: .light)
        config.secondaryTextProperties.font = .systemFont(ofSize: 15)
        config.secondaryTextProperties.color = HexCode.selected.color
        self.contentConfiguration = config
    }
    
    func bindingText(with viewModel: SettingCellViewModel) {
        config.text = viewModel.category.title
        
        viewModel.option.bind { [weak self] option in
            self?.config.secondaryText = option
        }
        
        self.contentConfiguration = config
    }
}
