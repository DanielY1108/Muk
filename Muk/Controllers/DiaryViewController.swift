//
//  DiaryViewController.swift
//  Muk
//
//  Created by JINSEOK on 2023/03/30.
//

import UIKit
import SnapKit
import PhotosUI

class DiaryViewController: UIViewController {
    
    // MARK: - Properties
    
    private let diaryView = DiaryView()
    
    // Identifier와 PHPickerResult로 만든 Dictionary (이미지 데이터를 저장하기 위해 만들어 줌)
    private var selections = [String: PHPickerResult]()
    // 선택한 사진의 순서에 맞게 Identifier들을 배열로 저장해줄 겁니다.
    private var selectedAssetIdentifiers = [String]()
    
    
    // MARK: - Life Cycle
    
    override func loadView() {
        self.view = diaryView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageTapGesture()
        setupButtons()
        setupDatePicker()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

// MARK: - Setup

extension DiaryViewController {
    
    // DiaryView 버튼 셋팅
    private func setupButtons() {
        diaryView.saveButton.addTarget(self, action: #selector(saveButtonHandler), for: .touchUpInside)
        diaryView.closeButton.addTarget(self, action: #selector(closeButtonHandler), for: .touchUpInside)
    }
    
    @objc func saveButtonHandler(_ sender: UIButton) {
        
    }
    
    @objc func closeButtonHandler(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    // DiaryView의 photoImageView를 클릭하면 동작하게 만듬
    private func imageTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageViewHandler))
        
        if let lastImageView = diaryView.photoStackView.subviews.last {
            lastImageView.isUserInteractionEnabled = true
            lastImageView.addGestureRecognizer(tap)
        }
    }
    
    @objc func imageViewHandler() {
        presentPicker()
    }

}

// MARK: - datePicker 설정 및 Toolbar 설정

extension DiaryViewController {
    
    // datePicker
    private func setupDatePicker() {
        
        let datePicker = UIDatePicker()
        // 표시될 날짜 형식 설정
        datePicker.datePickerMode = .date
        // 스타일 설정
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ko-KR")
        datePicker.addTarget(self, action: #selector(dateChange), for: .valueChanged)
        
        diaryView.dateTextField.inputView = datePicker
        diaryView.dateTextField.text = dateFormat(date: Date())
        
        setupToolBar()
    }
    
    @objc func dateChange(_ sender: UIDatePicker) {
        diaryView.dateTextField.text = dateFormat(date: sender.date)
    }
    
    // 날짜 형식 변환
    private func dateFormat(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy / MM / dd"
        
        return formatter.string(from: date)
    }
    
    // 툴바 설정
    private func setupToolBar() {
        let toolBar = UIToolbar()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonHandler))
        
        toolBar.sizeToFit()
        toolBar.items = [flexibleSpace, doneButton]
        
        diaryView.dateTextField.inputAccessoryView = toolBar
    }
    
    @objc func doneButtonHandler(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
    }
}

// MARK: - PHPickerViewControllerDelegate

extension DiaryViewController : PHPickerViewControllerDelegate {
    
    private func presentPicker() {
        // 이미지의 Identifier를 사용하기 위해서는 초기화를 shared로 해줘야 합니다.
        var config = PHPickerConfiguration(photoLibrary: .shared())
        // 라이브러리에서 보여줄 Assets을 필터를 한다. (기본값: 이미지, 비디오, 라이브포토)
        config.filter = PHPickerFilter.any(of: [.images])
        // 다중 선택 갯수 설정 (0 = 무제한)
        config.selectionLimit = 5
        // 선택 동작을 나타냄 (default: 기본 틱 모양, ordered: 선택한 순서대로 숫자로 표현, people: 뭔지 모르겠게요)
        config.selection = .ordered
        // 잘은 모르겠지만, current로 설정하면 트랜스 코딩을 방지한다고 하네요!?
        config.preferredAssetRepresentationMode = .current
        // 이 동작이 있어야 PHPicker를 실행 시, 선택했던 이미지를 기억해 표시할 수 있다. (델리게이트 코드 참고)
        config.preselectedAssetIdentifiers = selectedAssetIdentifiers
        
        // 만들어준 Configuration를 사용해 PHPicker 컨트롤러 객체 생성
        let imagePicker = PHPickerViewController(configuration: config)
        imagePicker.delegate = self
        
        UIFactory.halfModalPresent(controller: imagePicker)
        self.present(imagePicker, animated: true)
    }
    
    // 이미지를 받아 이미지뷰 추가 작업, 버튼의 이미지를 항상 마지막에 위치하고 싶어 index를 받아와서 설정
    private func addImageView(_ image: UIImage, index: Int) {
        let imageView = UIFactory.createCircleImageView(size: 90)
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        
        diaryView.photoStackView.insertArrangedSubview(imageView, at: index)
    }
    
    // 스택뷰 전체를 지우는 작업
    private func stackViewRemoveAllSubviews() {
        // 스크롤뷰의 콘텐츠 크기 조절
        photoContentViewInsetUpdate()

        diaryView.photoStackView.subviews.forEach {
            if $0 != diaryView.plusImageView {
                $0.removeFromSuperview()
            }
        }
    }
    
    private func displayImage() {
        
        let dispatchGroup = DispatchGroup()
        // identifier와 이미지로 dictionary를 만듬 (selectedAssetIdentifiers의 순서에 따라 이미지를 받을 예정입니다.)
        var imagesDict = [String: UIImage]()
        
        for (identifier, result) in selections {
            
            dispatchGroup.enter()
            
            let itemProvider = result.itemProvider
            // 만약 itemProvider에서 UIImage로 로드가 가능하다면?
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                // 로드 핸들러를 통해 UIImage를 처리해 줍시다. (비동기적으로 동작)
                itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    
                    guard let image = image as? UIImage else { return }
                    
                    imagesDict[identifier] = image
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) { [weak self] in
            guard let self = self else { return }
            
            // 먼저 스택뷰의 서브뷰들을 모두 제거함
            self.stackViewRemoveAllSubviews()
            
            // 선택한 이미지의 순서대로 정렬하여 스택뷰에 올리기
            for (index, identifier) in self.selectedAssetIdentifiers.enumerated() {
                guard let image = imagesDict[identifier] else { return }
                self.addImageView(image, index: index)
            }
        }
    }
    
    // picker가 종료되면 동작 합니다.
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        // picker가 선택이 완료되면 화면 내리기
        picker.dismiss(animated: true)
        
        // Picker의 작업이 끝난 후, 새로 만들어질 selections을 담을 변수를 생성
        var newSelections = [String: PHPickerResult]()
        
        for result in results {
            let identifier = result.assetIdentifier!
            // ⭐️ 여기는 WWDC에서 3분 부분을 참고하세요. (Picker의 사진의 저장 방식)
            newSelections[identifier] = selections[identifier] ?? result
        }
        
        // selections에 새로 만들어진 newSelection을 넣어줍시다.
        selections = newSelections
        // Picker에서 선택한 이미지의 Identifier들을 저장 (assetIdentifier은 옵셔널 값이라서 compactMap 받음)
        // 위의 PHPickerConfiguration에서 사용하기 위해서 입니다.
        selectedAssetIdentifiers = results.compactMap { $0.assetIdentifier }
        
        if selections.isEmpty {
            stackViewRemoveAllSubviews()
        } else {
            displayImage()
        }
    }
}

// MARK: - DiaryView의 스크롤뷰 델리게이트

extension DiaryViewController: UIScrollViewDelegate {
    // 스택뷰에 이미지를 추가함에 따라 스크롤뷰의 콘텐츠뷰의 크기를 증가시키는 메서드
    private func photoContentViewInsetUpdate() {
        diaryView.photoScrollView.delegate = self
        
        // 이미지가 추가될 때 마다 커지는 크기
        let imageSizeWithSpace = ((diaryView.imageSize) / 2) + diaryView.space
        var inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        // 현재 사진 갯수에 따라 크기를 키움
        for num in 0 ..< selections.count {
            inset.left = imageSizeWithSpace * CGFloat(num - 1)
        }
    
        // 이미지가 3개 이상일 때 contentInset 변경, 아니라면 초기화
        if selections.count >= 3 {
            diaryView.photoScrollView.contentInset = inset
        } else {
            diaryView.photoScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    // 콘텐츠뷰의 크기가 변할 때 마다 스크롤뷰의 위치를 이동 시켜줌, 스크롤뷰에서 보이는 화면을 마지막 버튼으로 이동
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        let x = scrollView.adjustedContentInset.left
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }

}



// MARK: - PreView 읽기
import SwiftUI

#if DEBUG
struct PreView3: PreviewProvider {
    static var previews: some View {
        // 사용할 뷰 컨트롤러를 넣어주세요
        DiaryViewController()
            .toPreview()
    }
}
#endif



