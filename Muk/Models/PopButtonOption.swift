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
            // 버튼에 들어가야 할 기능
            // 1. 위치를 검색하여 리스트 작성, 2. 현재 위치에서 리스트 작성, 3. 마지막 기능 아직 미정
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


