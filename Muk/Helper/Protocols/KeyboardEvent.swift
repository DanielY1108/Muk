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

// 키보드가 올라갈 때 화면도 같이 올라가게 하는 메서드
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
        // 현재 응답을 받는 UITextView의 크기를 전달받아 계산
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let currentTextView = UIResponder.currentResponder as? UITextView else { return }
        
        let keyboardTopY = keyboardFrame.cgRectValue.origin.y
        let convertedTextViewFrame = view.convert(currentTextView.frame,
                                                  from: currentTextView.superview)
        // 텍스트 카운트 label 높이 ~= 20
        let textViewBottomY = convertedTextViewFrame.origin.y + convertedTextViewFrame.size.height + 20

        // 텍스트뷰 바텀 위치가 키보드 탑 위치보다 클 때 (즉, 텍스트뷰가 키보드에 가려질 때)
        if textViewBottomY > keyboardTopY {
            let textViewTopY = convertedTextViewFrame.origin.y
            // 노가다를 통해서 모든 기종에 적절한 크기를 설정함.
            let newFrame = textViewTopY - keyboardTopY/1.6
            view.frame.origin.y -= newFrame
        }
    }
    
    private func keyboardWillDisappear(_ notification: Notification) {
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
}
