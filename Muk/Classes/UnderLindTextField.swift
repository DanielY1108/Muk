//
//  UnderLindTextField.swift
//  Muk
//
//  Created by JINSEOK on 2023/03/31.
//

import UIKit

final class UnderLindTextField: UITextField {
    
    private var placeholderColor: UIColor = UIColor.systemBackground
    
    private let underLineView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.textAlignment = .center
        addSubview(underLineView)
        
        underLineView.snp.makeConstraints {
            $0.top.equalTo(self.snp.bottom).offset(1)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        self.font = UIFont.preferredFont(forTextStyle: .subheadline)
        self.addSidePadding()

        self.addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
        self.addTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 플레이스홀더 세팅
    func setPlaceHolder(_ text: String, color: UIColor = .placeholderText) {
        placeholderColor = color
        
        let textAttribute = [NSAttributedString.Key.foregroundColor: placeholderColor]
        
        self.attributedPlaceholder = NSAttributedString(string: text,
                                                        attributes: textAttribute)
        
        underLineView.backgroundColor = color
    }
    
    // 텍스트 필드 양 사이드 공백주기
    func addSidePadding() {
        let size = CGSize(width: 5, height: self.frame.height)
        let paddingView = UIView(frame: CGRect(origin: .zero, size: size))
        
        self.rightView = paddingView
        self.rightViewMode = ViewMode.always
        self.leftView = paddingView
        self.leftViewMode = ViewMode.always
    }
    
}

extension UnderLindTextField {
    @objc func editingDidBegin() {
        underLineView.backgroundColor = HexCode.selected.color
    }
    
    @objc func editingDidEnd() {
        underLineView.backgroundColor = placeholderColor
    }
}
// MARK: - PreView 읽기
import SwiftUI

#if DEBUG
struct PreView6: PreviewProvider {
    static var previews: some View {
        // 사용할 뷰 컨트롤러를 넣어주세요
        DiaryViewController()
            .toPreview()
    }
}
#endif
