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
            // 1. 위치를 검색하여 리스트 작성, 2. 현재 위치에서 리스트 작성, 3. 지도에 직접 핀으로 선택해서 리스트 작성
            PopButtonOption(name: "Search", image: UIImage.imageWithRenderingModeAlwaysTemplate(named: "addSearch")!),
            PopButtonOption(name: "Current Location", image: UIImage(systemName: "plus")!),
            PopButtonOption(name: "Pin", image: UIImage.imageWithRenderingModeAlwaysTemplate(named: "addPin")!)
            ]
    }
}

// 탭바 pop 버튼에 사용할 데이터
struct PopButtonOption {
    var name: String
    var image: UIImage
}


