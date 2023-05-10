//
//  NotificationProtocol.swift
//  Muk
//
//  Created by JINSEOK on 2023/05/09.
//

import UIKit

// 이름을 추가해서 사용하자
enum NotificationNameIs: NotificationProtocol {
    
    case saveButton
    
    var name: Notification.Name {
        switch self {
        case .saveButton:
            return Notification.Name("Save Button")
        }
    }
}


protocol NotificationProtocol {
    var name: Notification.Name { get }
}

extension NotificationProtocol  {
    
    func startNotification(_ completion: @escaping (Notification) -> Void) {
        NotificationCenter.default.addObserver(forName: name,
                                               object: nil,
                                               queue: nil) { notification in
            completion(notification)
        }
    }
    
    func stopNotification() {
        NotificationCenter.default.removeObserver(self, name: name, object: nil)
    }
    
    func postNotification(with object: Any?) {
        NotificationCenter.default.post(name: name, object: object)
    }
}
