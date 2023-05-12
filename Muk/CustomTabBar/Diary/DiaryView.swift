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
    private let detailTextViewPlaceHolder = "내용을 입력해주세요."
    lazy var detailTextView = UIFactory.createDiaryTextView(placeHolder: detailTextViewPlaceHolder)
    private lazy var detailStackView = UIFactory.createDiaryStackView(arrangedSubviews: [detailLabel, detailTextView])
    
    private let detailTextViewLetterCountLabel = UIFactory.createTextViewCountLabel()
    
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
        
        self.addSubview(detailTextViewLetterCountLabel)
        detailTextViewLetterCountLabel.snp.makeConstraints {
            $0.top.equalTo(detailStackView.snp.bottom).offset(space)
            $0.trailing.equalTo(detailStackView).offset(-space)
        }
        
        self.addSubview(saveButton)
        saveButton.snp.makeConstraints {
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(space)
            $0.leading.trailing.equalToSuperview().inset(sideInset*2)
        }
        
        configUI()
        setupTextField()
        setupButtons()
    }
    
    private func configUI() {
        detailTextView.delegate = self
        
        self.backgroundColor = HexCode.tabBarBackground.color
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

// MARK: - 텍스트뷰 델리게이트

extension DiaryView: UITextViewDelegate {
    
    // Placeholder 세팅
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.layer.borderWidth = 1
        
        if textView.text == detailTextViewPlaceHolder {
            detailTextView.text = nil
            detailTextView.textColor = .black
        }
    }
    
    // Placeholder 세팅
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.layer.borderWidth = 0
        
        // 띄어쓰기, 즉 공백만 있을 경우 공백을 제거하고 플레이스 홀더를 나오게 만듬
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            detailTextView.text = detailTextViewPlaceHolder
            detailTextView.textColor = .placeholderText
        }
    }
    
    // 동적으로 텍스트뷰 크기 조정
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: detailStackView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { constraint in
            // 3줄(80)보다 크고 5줄 (120)보다 작을 때 동작
            if estimatedSize.height >= 80 && estimatedSize.height <= 120 {
                constraint.constant = estimatedSize.height
            }
        }
        
        // 글자수 카운트
        detailTextViewLetterCountLabel.text = "\(textView.text.count)"
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
        dateTextField.text = DateFormatter.custom(date: Date())
        
        setupToolBar()
    }
    
    @objc func dateChange(_ sender: UIDatePicker) {
        dateTextField.text = DateFormatter.custom(date: sender.date)
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

