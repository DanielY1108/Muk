//
//  PopButtonOption.swift
//  Muk
//
//  Created by JINSEOK on 2023/03/21.
//

import UIKit

struct PopButtons {
    var buttons: [UIButton]
    var options: [PopButtonOption]
    
    init() {
        self.buttons = []
        self.options = [
            PopButtonOption(name: "Trash", image: UIImage(systemName: "trash")!),
            PopButtonOption(name: "Add", image: UIImage(systemName: "plus")!),
            PopButtonOption(name: "Edit", image: UIImage(systemName: "eraser")!)
            ]
    }
}

// 탭바 pop 버튼에 사용할 데이터
struct PopButtonOption {
    var name: String
    var image: UIImage
}


