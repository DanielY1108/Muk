//
//  String.swift
//  Muk
//
//  Created by JINSEOK on 2023/03/28.
//

import UIKit

extension String {
    
    // addingPercentEncoding 공백과 같은 인식이 불가능한 문자열을 변환시켜 사용가능하게 만들어 줌
    var stringByAddingPercentEncoding: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
}
