//
//  SearchMapAlertView.swift
//  Muk
//
//  Created by JINSEOK on 2023/06/14.
//

import UIKit

class SearchMapAlertView: UIView {

    let baseView = UIView()
    private let titleLabel = UILabel()
    private let messegeLable = UILabel()
    private let doneButton = UIButton()
    private let cancelButton = UIButton()
    
    var titleText: String?
    var messegeTitle: String?
    
    convenience init(title: String, messege: String) {
        self.init()
        
        self.titleText = title
        self.messegeTitle = messege
        setupUI()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)

        // UIButton이면 터치 이벤트가 포함된 뷰를 리턴, 나머지 동작 없음
        if hitView is UIButton {
            return hitView
        } else {
            return nil
        }
    }

    private func setupUI() {
        self.backgroundColor = .clear
        
        baseView.backgroundColor = HexCode.background.color
        baseView.layer.cornerRadius = 15
        
        titleLabel.font = .preferredFont(forTextStyle: .body)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.text = titleText
        
        messegeLable.font = .preferredFont(forTextStyle: .footnote)
        messegeLable.textColor = .secondaryLabel
        messegeLable.textAlignment = .center
        messegeLable.numberOfLines = 0
        messegeLable.text = messegeTitle
        
        var doneButtonConfig = UIButton.Configuration.filled()
        doneButtonConfig.cornerStyle = .large
        doneButtonConfig.buttonSize = .medium
        doneButtonConfig.baseBackgroundColor = HexCode.selected.color
        let doneButtonAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .bold),
            .foregroundColor: HexCode.background.color
        ]
        let doneButtonAttributedTitle = NSAttributedString(string: "여기에요!", attributes: doneButtonAttributes)
        doneButtonConfig.attributedTitle = AttributedString(doneButtonAttributedTitle)
        doneButton.configuration = doneButtonConfig
        
        var cancelButtonConfig = UIButton.Configuration.filled()
        cancelButtonConfig.cornerStyle = .large
        cancelButtonConfig.buttonSize = .medium
        cancelButtonConfig.baseBackgroundColor = HexCode.unselected.color
        let cancelButtonAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .bold),
            .foregroundColor: UIColor.secondaryLabel
        ]
        let cancelButtonAttributedTitle = NSAttributedString(string: "여기가 아니에요", attributes: cancelButtonAttributes)
        cancelButtonConfig.attributedTitle = AttributedString(cancelButtonAttributedTitle)
        cancelButton.configuration = cancelButtonConfig
        
        self.setupLayout()
    }
    
    private func setupLayout() {
        self.addSubview(baseView)
        baseView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.bottom.equalToSuperview().inset(70)
            $0.height.equalTo(180)
        }
        
        let titleStack = UIStackView(arrangedSubviews: [titleLabel, messegeLable])
        titleStack.axis = .vertical
        titleStack.distribution = .fillEqually
        titleStack.spacing = 10
        
        baseView.addSubview(titleStack)
        titleStack.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(20)
        }
        
        let buttonStack = UIStackView(arrangedSubviews: [doneButton, cancelButton])
        buttonStack.axis = .vertical
        buttonStack.distribution = .fillProportionally
        buttonStack.spacing = 10
        
        baseView.addSubview(buttonStack)
        buttonStack.snp.makeConstraints {
            $0.top.equalTo(titleStack.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.bottom.equalToSuperview().inset(10)
        }
    }
}
