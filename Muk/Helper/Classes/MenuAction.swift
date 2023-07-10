//
//  CreateMenuAction.swift
//  Muk
//
//  Created by JINSEOK on 2023/07/10.
//

import UIKit

enum MenuOption: String {
    case descendingByDate = "최신 날짜순"
    case ascendingByDate = "이전 날짜순"
}

struct MenuAction {
    var option: MenuOption
    var handler: (UIAction) -> Void
    
    init(_ option: MenuOption, handler: @escaping (UIAction) -> Void) {
        self.option = option
        self.handler = handler
    }
}
