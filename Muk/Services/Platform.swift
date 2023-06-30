//
//  Platform.swift
//  Muk
//
//  Created by JINSEOK on 2023/03/29.
//

import Foundation


enum Platform: String {
    
    case kakao
    
    // plist에서 key으로 사용할 platform을 적어 줬으므로 사용할 key값만 정해주자. (아래 코드는 건드릴 필요 없음)
    var key: String {
        switch self {
        case .kakao:
            return "Authorization"
        }
    }
    
    // dictionary의 value값 읽기
    var value: String {
        
        guard let value = parsePlist.object(forKey: self.rawValue) as? String else {
            fatalError("Couldn't find 'Key value' in 'SecureAPIKeys.plist'.")
        }
        
        return value
    }
    
    // plist를 읽는 작업 (dictionary로 리턴)
    private var parsePlist: NSDictionary {
        
        guard let plistUrl = Bundle.main.url(forResource: "SecureAPIKeys", withExtension: "plist") else {
            fatalError("Couldn't find file 'SecureAPIKeys.plist'.")
        }
        
        guard let plistData = try? Data(contentsOf: plistUrl),
              let dict = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? NSDictionary
        else {
            fatalError("Couldn't load dictionary from data.")
        }
        
        return dict
    }
}
