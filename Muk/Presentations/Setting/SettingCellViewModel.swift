//
//  SettingViewModel.swift
//  Muk
//
//  Created by JINSEOK on 2023/07/02.
//

import Foundation

class SettingCellViewModel {
    let category: SettingCategory
    var option: Observable<String?>
    
    init(category: SettingCategory, option: String? = nil) {
        self.category = category
        self.option = Observable(option)
    }
}
