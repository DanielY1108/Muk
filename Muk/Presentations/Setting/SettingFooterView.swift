//
//  SettingFooterView.swift
//  Muk
//
//  Created by JINSEOK on 2023/06/28.
//

import UIKit

class SettingFooterView: UITableViewHeaderFooterView {
    
    private var separatorView: UIView!

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configUI() {
        separatorView = UIView()
        separatorView.backgroundColor = HexCode.tabBarBackground.color
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview().inset(16)
        }        
    }
}
