//
//  DiaryView.swift
//  Muk
//
//  Created by JINSEOK on 2023/03/30.
//

import UIKit

protocol DiaryViewDelegate: AnyObject {
    func saveOrEditButtonTapped(_ view: DiaryView)
    func closeButtonTapped(_ view: DiaryView)
}

final class DiaryView: UIView {
    
    weak var delegate: DiaryViewDelegate?
    
    // MARK: - Properties
    
    let closeButton = UIFactory.createCloseButton()
    let saveOrEditButton = UIFactory.createSaveOrEditButton()
    
    private let titleLabel = UIFactory.createDiaryLabel(title: "추억하기")
    let dateTextField = UnderLindTextField()
    
    private let placeNameLabel = UIFactory.createDiaryLabel(title: "장소")
    let placeTextField = UnderLindTextField()
    let locationTextField = UnderLindTextField()
    private lazy var placeNameStackView = UIFactory.createDiaryStackView(arrangedSubviews: [placeNameLabel, placeTextField, locationTextField])
    
    private let detailLabel = UIFactory.createDiaryLabel(title: "내용")
    let detailTextViewPlaceHolder = "내용을 입력해 주세요."
    lazy var detailTextView = UIFactory.createDiaryTextView(placeHolder: detailTextViewPlaceHolder)
    lazy var detailStackView = UIFactory.createDiaryStackView(arrangedSubviews: [detailLabel, detailTextView])
    
    let detailTextViewLetterCountLabel = UIFactory.createTextViewCountLabel()
    
    private let photoLabel = UIFactory.createDiaryLabel(title: "사진")
    
    let photoScrollView = UIScrollView()
    
    lazy var plusImageView = UIFactory.createCircleImageView(size: imageSize)
    lazy var photoStackView = UIFactory.createDiaryStackView(arrangedSubviews: [plusImageView],
                                                             distribution: .fillEqually,
                                                             axis: .horizontal)
    
    // MARK: - Size Properties
    
    private let titleGap: CGFloat = 30
    private let sideInset: CGFloat = 40
    let space: CGFloat = 10
    let imageSize: CGFloat = 90
    
    // MARK: - Life Cyclesd
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        
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
        
        self.addSubview(detailTextViewLetterCountLabel)
        detailTextViewLetterCountLabel.snp.makeConstraints {
            $0.top.equalTo(detailStackView.snp.bottom).offset(space)
            $0.trailing.equalTo(detailStackView).offset(-space)
        }
        
        self.addSubview(saveOrEditButton)
        saveOrEditButton.snp.makeConstraints {
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(space)
            $0.leading.trailing.equalToSuperview().inset(sideInset*2)
        }
        
        configUI()
        setupTextField()
        setupButtonsAction()
    }
    
    private func configUI() {
        self.backgroundColor = HexCode.tabBarBackground.color
        titleLabel.font = .preferredFont(forTextStyle: .title3)
        
        // 자동 교정하지 않게 만들기
        placeTextField.autocorrectionType = .no
        // 자동 대문자 사용 안함
        placeTextField.autocapitalizationType = .none
        // 맞춤법 검사
        placeTextField.spellCheckingType = .no
        
        saveOrEditButton.isEnabled = false
    }
    
    private func setupTextField() {
        dateTextField.setPlaceHolder("2023년 05월 24일")
        placeTextField.setPlaceHolder("장소를 입력해 주세요.")
        locationTextField.setPlaceHolder("주소를 확인해 주세요.")
    }
    
    // DiaryView 버튼 셋팅
    private func setupButtonsAction() {
        saveOrEditButton.addTarget(self, action: #selector(saveOrEditButtonHandler), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeButtonHandler), for: .touchUpInside)
    }
    
    func confirmButtonActivation() {
        guard let placeName = placeTextField.text else { return }
        
        if placeName.isEmpty {
            saveOrEditButton.isEnabled = false
            saveOrEditButton.backgroundColor = .clear
        } else {
            saveOrEditButton.isEnabled = true
            saveOrEditButton.backgroundColor = HexCode.unselected.color
        }
    }
}

// MARK: - Buttom Handler

extension DiaryView {
    
    @objc func saveOrEditButtonHandler(_ sender: UIButton) {
        delegate?.saveOrEditButtonTapped(self)
    }
    
    @objc func closeButtonHandler(_ sender: UIButton) {
        delegate?.closeButtonTapped(self)
    }
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

