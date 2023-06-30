//
//  SettingCell.swift
//  Muk
//
//  Created by JINSEOK on 2023/06/28.
//

import UIKit

class SettingCell: UITableViewCell {
    
    var name: Observable<String> = Observable("")
    var option: Observable<String> = Observable("")

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = HexCode.background.color
        
        var config = self.defaultContentConfiguration()
        config.prefersSideBySideTextAndSecondaryText = true
        config.textProperties.font = .systemFont(ofSize: 15, weight: .light)
        config.secondaryTextProperties.font = .systemFont(ofSize: 15)
        config.secondaryTextProperties.color = HexCode.selected.color
        
        name.bind { name in
            config.text = name
            self.contentConfiguration = config
        }
        
        option.bind { option in
            config.secondaryText = option
            self.contentConfiguration = config
        }
        
    }
}
