//
//  KeyboardEvent.swift
//  Muk
//
//  Created by JINSEOK on 2023/05/08.
//

import UIKit

protocol KeyboardEvent where Self: UIViewController {
    var transformView: UIView { get }
    func setupKeyboardEvent()
}

// FIXME: - 오직 디테일 텍스트뷰에서만 키보드를 동작시 올라가게 만들고 싶다.

extension KeyboardEvent where Self: UIViewController {
    func setupKeyboardEvent() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification,
                                               object: nil,
                                               queue: OperationQueue.main) { [weak self] notification in
            self?.keyboardWillAppear(notification)
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                               object: nil,
                                               queue: OperationQueue.main) { [weak self] notification in
            self?.keyboardWillDisappear(notification)
        }
    }
    
    func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func keyboardWillAppear(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
                
        if transformView.frame.origin.y == 0 {
            transformView.frame.origin.y -= keyboardHeight
        }
    }
    
    private func keyboardWillDisappear(_ notification: Notification) {
        if transformView.frame.origin.y != 0 {
            transformView.frame.origin.y = 0
        }
    }
}
