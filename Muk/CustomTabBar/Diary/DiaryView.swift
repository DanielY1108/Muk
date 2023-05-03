//
//  DiaryView.swift
//  Muk
//
//  Created by JINSEOK on 2023/03/30.
//

import UIKit

protocol DiaryViewDelegate: AnyObject {
    func saveButtonTapped(_ view: DiaryView)
    func closeButtonTapped(_ view: DiaryView)
}

final class DiaryView: UIView {
    
   weak var delegate: DiaryViewDelegate?
    
    // MARK: - Properties
    
    let closeButton = UIFactory.createCloseButton()
    let saveButton = UIFactory.createSaveButton()
    
    private let titleLabel = UIFactory.createDiaryLabel(title: "추억하기")
    let dateTextField = UnderLindTextField()
    
    private let placeNameLabel = UIFactory.createDiaryLabel(title: "장소")
    let placeTextField = UnderLindTextField()
    let locationTextField = UnderLindTextField()
    private lazy var placeNameStackView = UIFactory.createDiaryStackView(arrangedSubviews: [placeNameLabel, placeTextField, locationTextField])
    
    private let detailLabel = UIFactory.createDiaryLabel(title: "내용")
    let detailTextView = UIFactory.createDiaryTextView(placeHolder: "내용을 입력하세요.")
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
        
        setupUI()
        setupTextField()
        setupButtons()
        setupDatePicker()
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
        
        self.addSubview(saveButton)
        saveButton.snp.makeConstraints {
            $0.bottom.equalTo(self.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview().inset(sideInset*2)
        }
        
        configUI()
        setupTextField()
        setupButtons()
    }
    
    private func configUI() {
        self.backgroundColor = HexCode.background.color
        titleLabel.font = .preferredFont(forTextStyle: .title3)
    }
    
    private func setupTextField() {
        dateTextField.setPlaceHolder("2023 / 04 / 03")
        placeTextField.setPlaceHolder("장소를 입력해주세요.")
        locationTextField.setPlaceHolder("주소를 확인해주세요.")
    }
    
    // DiaryView 버튼 셋팅
    private func setupButtons() {
        saveButton.addTarget(self, action: #selector(saveButtonHandler), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeButtonHandler), for: .touchUpInside)
    }
    
    
}

// MARK: - datePicker 설정 및 Toolbar 설정

extension DiaryView {
    // datePicker
    private func setupDatePicker() {
        
        let datePicker = UIDatePicker()
        // 표시될 날짜 형식 설정
        datePicker.datePickerMode = .date
        // 스타일 설정
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ko-KR")
        datePicker.addTarget(self, action: #selector(dateChange), for: .valueChanged)
        
        dateTextField.inputView = datePicker
        dateTextField.text = dateFormat(date: Date())
        
        setupToolBar()
    }
    
    @objc func dateChange(_ sender: UIDatePicker) {
        dateTextField.text = dateFormat(date: sender.date)
    }
    
    // 날짜 형식 변환
    private func dateFormat(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy / MM / dd"
        
        return formatter.string(from: date)
    }
    
    // DatePicker 툴바 설정
    private func setupToolBar() {
        let toolBar = UIToolbar()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonHandler))
        
        toolBar.sizeToFit()
        toolBar.items = [flexibleSpace, doneButton]
        
        dateTextField.inputAccessoryView = toolBar
    }
    
    @objc func doneButtonHandler(_ sender: UIBarButtonItem) {
        print("DatePicker 선택 완료")
        self.endEditing(true)
    }
}

// MARK: - Buttom Handler

extension DiaryView {
    
    @objc func saveButtonHandler(_ sender: UIButton) {
        delegate?.saveButtonTapped(self)
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
