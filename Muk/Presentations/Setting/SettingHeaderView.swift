//
//  SettingHeaderView.swift
//  Muk
//
//  Created by JINSEOK on 2023/06/28.
//

import UIKit

class SettingHeaderView: UITableViewHeaderFooterView {
    
    private var config: UIListContentConfiguration!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        config = self.defaultContentConfiguration()
        config.textProperties.font = .systemFont(ofSize: 17, weight: .black)
        config.textProperties.color = HexCode.selected.color
        self.contentConfiguration = config
    }
    
    func setupText(_ text: String) {
        config.text = text
        self.contentConfiguration = config
    }
}
