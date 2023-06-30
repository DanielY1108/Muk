//
//  SettingHeaderView.swift
//  Muk
//
//  Created by JINSEOK on 2023/06/28.
//

import UIKit

class SettingHeaderView: UITableViewHeaderFooterView {
    
    var name: Observable<String> = Observable("")

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        var config = self.defaultContentConfiguration()
        config.textProperties.font = .systemFont(ofSize: 17, weight: .black)
        config.textProperties.color = HexCode.selected.color
        
        name.bind { name in
            config.text = name
            self.contentConfiguration = config
        }
    }
}
