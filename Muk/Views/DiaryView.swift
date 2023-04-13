//
//  DiaryView.swift
//  Muk
//
//  Created by JINSEOK on 2023/03/30.
//

import UIKit

class DiaryView: UIView {
    
    // MARK: - Properties
    
    let closeButton = UIFactory.createCloseButton()
    let saveButton = UIFactory.createSaveButton()
    
    private let titleLabel = UIFactory.createDiaryLabel(title: "추억하기")
    let dateTextField = UnderLindTextField()
    
    private let placeNameLabel = UIFactory.createDiaryLabel(title: "장소")
    private let placeTextField = UnderLindTextField()
    private let locationTextField = UnderLindTextField()
    private lazy var placeNameStackView = UIFactory.createDiaryStackView(arrangedSubviews: [placeNameLabel, placeTextField, locationTextField])
    
    private let detailLabel = UIFactory.createDiaryLabel(title: "내용")
    private let detailTextView = UIFactory.createDiaryTextView(placeHolder: "내용을 입력하세요.")
    private lazy var detailStackView = UIFactory.createDiaryStackView(arrangedSubviews: [detailLabel, detailTextView])
    
    private let photoLabel = UIFactory.createDiaryLabel(title: "사진")
    
    let photoScrollView = UIScrollView()
    
    lazy var plusImageView = UIFactory.createCircleImageView(size: imageSize)
    lazy var photoStackView = UIFactory.createDiaryStackView(arrangedSubviews: [plusImageView],
                                                             distribution: .fillEqually,
                                                             axis: .horizontal)
    
    // MARK: - Size Properties
    
    private let titleGap: CGFloat = 30
    let space: CGFloat = 10
    private let sideInset: CGFloat = 40
    let imageSize: CGFloat = 90
    
    // MARK: - Life Cyclesd
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupStackViewLayout()
        setupTextField()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupStackViewLayout() {
        
        self.addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(space)
            $0.leading.equalToSuperview().inset(space)
        }
        
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(closeButton.snp.centerY)
            $0.centerX.equalToSuperview()
        }
        
        self.addSubview(photoLabel)
        photoLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(titleGap)
            $0.leading.trailing.equalToSuperview()
        }
        
        self.addSubview(photoScrollView)
        photoScrollView.snp.makeConstraints {
            $0.top.equalTo(photoLabel.snp.bottom).offset(titleGap-space)
            $0.trailing.leading.equalToSuperview().inset(sideInset)
            $0.height.equalTo(imageSize+space)
        }
        
        photoScrollView.addSubview(photoStackView)
        photoStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        
        self.addSubview(dateTextField)
        dateTextField.snp.makeConstraints {
            $0.top.equalTo(photoStackView.snp.bottom).offset(titleGap)
            $0.centerX.equalToSuperview()
        }
        
        self.addSubview(placeNameStackView)
        placeNameStackView.snp.makeConstraints {
            $0.top.equalTo(dateTextField.snp.bottom).offset(titleGap)
            $0.leading.trailing.equalToSuperview().inset(sideInset)
        }
        
        self.addSubview(detailStackView)
        detailStackView.snp.makeConstraints {
            $0.top.equalTo(placeNameStackView.snp.bottom).offset(titleGap)
            $0.leading.trailing.equalToSuperview().inset(sideInset)
        }
        
        self.addSubview(saveButton)
        saveButton.snp.makeConstraints {
            $0.bottom.equalTo(self.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview().inset(sideInset*2)
        }
    }
    
    private func setupTextField() {
        dateTextField.setPlaceHolder("2023 / 04 / 03")
        placeTextField.setPlaceHolder("장소를 입력해주세요.")
        locationTextField.setPlaceHolder("주소를 확인해주세요.")
    }
    
    private func setupUI() {
        self.backgroundColor = HexCode.background.color
        titleLabel.font = .preferredFont(forTextStyle: .title3)
    }
}

// MARK: - Method

extension DiaryView {
    
}


// MARK: - PreView 읽기
import SwiftUI

#if DEBUG
struct PreView4: PreviewProvider {
    static var previews: some View {
        // 사용할 뷰 컨트롤러를 넣어주세요
        DiaryViewController()
            .toPreview()
    }
}
#endif

