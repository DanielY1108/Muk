//
//  CreateMenuAction.swift
//  Muk
//
//  Created by JINSEOK on 2023/07/10.
//

import UIKit

enum MenuOption: String {
    case descendingByDate = "날짜별 내림차순"
    case ascendingByDate = "날짜별 오름차순"
}

struct MenuAction {
    var option: MenuOption
    var handler: (UIAction) -> Void
    
    init(_ option: MenuOption, handler: @escaping (UIAction) -> Void) {
        self.option = option
        self.handler = handler
    }
}
