//
//  Observable.swift
//  Muk
//
//  Created by JINSEOK on 2023/04/24.
//

import Foundation

class Observable<T> {
    
    // 2. value가 변하면 didSet에 의해 변경된 value 값을 갖고 listener 동작을 실행합니다.
    var value: T? {
        didSet {
            self.listener?(value)
        }
    }
    
    init(_ value: T?) {
        self.value = value
    }
    
    // listener: 동작을 담아두는 클로저
    private var listener: ((T?) -> Void)?
    
    // 이 함수를 통해 아래 작업을 수행
    // 1. completion에서 value의 값을 갖고 동작을 저장해 줍니다.
    func bind(_ listener: @escaping (T?) -> Void) {
        listener(value)
        self.listener = listener
    }
    
}
