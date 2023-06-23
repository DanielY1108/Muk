//
//  DiaryViewController.swift
//  Muk
//
//  Created by JINSEOK on 2023/03/30.
//

import UIKit
import SnapKit
import PhotosUI

final class DiaryViewController: UIViewController {
    
    // MARK: - Properties
    
    private(set) var viewModel = DiaryViewModel()

    private(set) var diaryView = DiaryView()
    // Identifier와 PHPickerResult로 만든 Dictionary (이미지 데이터를 저장하기 위해 만들어 줌)
    private(set) var selections = [String: PHPickerResult]()
    
    // MARK: - Life Cycle
    
    override func loadView() {
        self.view = diaryView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        binding(on: diaryView)
        setupUI()
        setupDatePicker()
        setupKeyboardEvent()
        loadDatabaseImagesAddImageView(on: diaryView)
        // 처음 수정할 때, 그 순간의 이미지 식별자 데이타가 필요하다. 따로 변수를 만들어줘서 담아줌
        viewModel.saveSelectedAssetIdentifierWhenEditing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        print("viewwillappear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeKeyboardObserver()
    }
    
    deinit {
        print("다이어리 컨트롤러 해제")
    }
}

// MARK: - Setup

extension DiaryViewController {
    
    func binding(on view: DiaryView) {
        viewModel.diaryModel.bind { model in
            DispatchQueue.main.async {
                view.dateTextField.text = DateFormatter.custom(date: model.date)
                view.placeTextField.text = model.placeName
                view.addressTextField.text = model.addressName
                view.detailTextView.text = model.detailText
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func setupUI() {
        diaryView.delegate = self
        diaryView.photoScrollView.delegate = self
        diaryView.detailTextView.delegate = self
        diaryView.placeTextField.delegate = self
        diaryView.addressTextField.delegate = self
        // 처음에 place 이름이 있으면 버튼을 활성화
        diaryView.confirmButtonActivation()

        imageTapGesture()
    }
    
    // DiaryView의 photoImageView의 마지막 "+" 이지미를 클릭하면 동작하게 만듬
    private func imageTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageViewHandler))
        
        if let lastImageView = diaryView.photoStackView.subviews.last {
            lastImageView.isUserInteractionEnabled = true
            lastImageView.addGestureRecognizer(tap)
        }
    }
    
    // "+" 이미지 클릭 시 포토 피커 생성
    @objc func imageViewHandler() {
        self.view.endEditing(true)
        presentPicker()
    }
}

// MARK: - PHPickerViewControllerDelegate & setup

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
        config.preselectedAssetIdentifiers = viewModel.diaryModel.value.selectedAssetIdentifiers
        
        // 만들어준 Configuration를 사용해 PHPicker 컨트롤러 객체 생성
        let imagePicker = PHPickerViewController(configuration: config)
        imagePicker.delegate = self
        
        UIFactory.halfModalPresent(controller: imagePicker)
        self.present(imagePicker, animated: true)
    }
    
    // 이미지를 받아 스택뷰에 이미지뷰 추가 작업, 버튼의 이미지를 항상 마지막에 위치하고 싶어 index를 받아와서 설정
    private func addImageView(on view: DiaryView, image: UIImage, index: Int) {
        let imageView = UIFactory.createCircleImageView(size: 90)
        imageView.image = image
        
        view.photoStackView.insertArrangedSubview(imageView, at: index)
    }
    
    // ProfileVC에서 셀을 수정할 때, 이 메서드가 실행되게 만들어야 함
    private func loadDatabaseImagesAddImageView(on view: DiaryView) {
        guard let images = viewModel.loadImagesFromDatabase() else {
            print("이미지가 비어 있습니다. 추가 작업 필요 없음!")
            return
        }
        
        stackViewRemoveAllSubviews(on: view)
        print("파일매니져에서 전달 받은 이지미 \(images) ")
        for (index, image) in images.enumerated() {
            let imageView = UIFactory.createCircleImageView(size: 90)
            imageView.image = image
            
            view.photoStackView.insertArrangedSubview(imageView, at: index)
        }
    }
    
    // 스택뷰 전체를 지우는 작업
    private func stackViewRemoveAllSubviews(on view: DiaryView) {
        // 스크롤뷰의 콘텐츠 크기 조절
        photoContentViewInsetUpdate(view)
        
        view.photoStackView.subviews.forEach {
            if $0 != view.plusImageView {
                $0.removeFromSuperview()
            }
        }
    }
    
    // 스택뷰에 이미지를 추가함에 따라 스크롤뷰의 콘텐츠뷰의 크기를 증가시키는 메서드
    private func photoContentViewInsetUpdate(_ view: DiaryView) {
        // 이미지가 추가될 때 마다 커지는 크기
        let imageSizeWithSpace = ((view.imageSize) / 2) + view.space
        var inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        // 현재 사진 갯수에 따라 크기를 키움
        for num in 0 ..< viewModel.diaryModel.value.selectedAssetIdentifiers.count {
            inset.left = imageSizeWithSpace * CGFloat(num - 1)
        }
        
        // 이미지가 3개 이상일 때 contentInset 변경, 아니라면 초기화
        if viewModel.diaryModel.value.selectedAssetIdentifiers.count >= 3 {
            view.photoScrollView.contentInset = inset
        } else {
            view.photoScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    // 이미지를 받아오는 작업 + 아래의 이미지뷰 추가 작업까지
    private func displayImage(on view: DiaryView) {
        
        let dispatchGroup = DispatchGroup()
        // identifier와 이미지로 dictionary를 만듬 (selectedAssetIdentifiers의 순서에 따라 이미지를 받을 예정입니다.)
        var imagesDict = [String: UIImage]()

        for (identifier, result) in selections {
            let itemProvider = result.itemProvider
            
            // 만약 itemProvider에서 UIImage로 로드가 가능하다면?
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                
                dispatchGroup.enter()
                // 이미지의 url을 받아 다운샘플링하는 동작을 정의함 (비동기적으로 동작)
                itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, error in
                    defer { dispatchGroup.leave() }
                    
                    guard let url = url else { return }
                    let image = UIImage.downsampleImage(imageAt: url, to: CGSize(width: 1000, height: 1000))
                    imagesDict[identifier] = image
                }
            }
        }
        
        // 이미지 수정 할 때, 만약 results의 식별자가 존재한다면, 즉 선택한 이미지가 같으면 이미지를 제외한 메타데이터를 전달하게 된다.
        // 이미지가 없다면, 저장된 식별자에 이미지 추가 작업을 해준다.
        if let images = self.viewModel.diaryModel.value.images,
           let selectedAssetIdentifiers = viewModel.selectedAssetIdentifiers {
            
            for (index, identifier) in selectedAssetIdentifiers.enumerated() {
                imagesDict[identifier] = images[index]
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) { [weak self] in
            guard let self = self else { return }
            
            // 먼저 스택뷰의 서브뷰들을 모두 제거함
            self.stackViewRemoveAllSubviews(on: view)
            // 기존에 저장된 이미지를 제거함 (이 로직이 이미지를 다 지우고 다시 읽어오는 것이므로 만약 이미지 수정 시
            // ProfileVC의 이미지가 선택한 이미지 + 수정한 이미지로 계속 추가되서 나타남)
            self.viewModel.makeEmptyImages()
            
            // 선택한 이미지의 순서대로 정렬하여 스택뷰에 올리기
            for (index, identifier) in self.viewModel.diaryModel.value.selectedAssetIdentifiers.enumerated() {
                guard let image = imagesDict[identifier] else { return }
                print("여긴 저장된 이미지 순서 \(image)")
                self.addImageView(on: view, image: image, index: index)
                // 밖에서 사용하기 위해서 만들어 줌
                self.viewModel.insertImage(image: image, at: index)
            }
            // 이때가 picker 델리게이트가 종료 되는 순간이다. 또 다시 수정할 수 있으므로 따로 변수로 만든 식별자를 업데이트 시켜준다.
            viewModel.saveSelectedAssetIdentifierWhenEditing()
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
        viewModel.diaryModel.value.selectedAssetIdentifiers = results.compactMap { $0.assetIdentifier }
        
        if selections.isEmpty {
            stackViewRemoveAllSubviews(on: diaryView)
        } else {
            displayImage(on: diaryView)
        }
    }
}

// MARK: - DiaryView의 이미지 스크롤뷰 델리게이트

extension DiaryViewController: UIScrollViewDelegate {    
    // 콘텐츠뷰의 크기가 변할 때 마다 스크롤뷰의 위치를 이동 시켜줌, 스크롤뷰에서 보이는 화면을 마지막 버튼으로 이동
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        let x = scrollView.adjustedContentInset.left
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }
    
}

// MARK: - datePicker 설정 및 Toolbar 설정

extension DiaryViewController {
    // datePicker
    private func setupDatePicker() {
        // 표시될 날짜 형식 설정
        viewModel.datePicker.datePickerMode = .date
        // 스타일 설정
        viewModel.datePicker.preferredDatePickerStyle = .wheels
        viewModel.datePicker.locale = Locale(identifier: "ko-KR")
        viewModel.datePicker.addTarget(self, action: #selector(dateChange), for: .valueChanged)
        
        diaryView.dateTextField.inputView = viewModel.datePicker
        
        if diaryView.dateTextField.text!.isEmpty {
            diaryView.dateTextField.text = DateFormatter.custom(date: Date())
        }
        setupToolBar()
    }
    
    @objc func dateChange(_ sender: UIDatePicker) {
        viewModel.diaryModel.value.date = sender.date
    }
    
    // DatePicker 툴바 설정
    private func setupToolBar() {
        let toolBar = UIToolbar()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonHandler))
        
        toolBar.sizeToFit()
        toolBar.items = [flexibleSpace, doneButton]
        
        diaryView.dateTextField.inputAccessoryView = toolBar
    }
    
    @objc func doneButtonHandler(_ sender: UIBarButtonItem) {
        print("DatePicker 선택 완료")
        self.view.endEditing(true)
    }
}

// MARK: - 텍스트필드 델리게이트

extension DiaryViewController: UITextFieldDelegate {
    
    // 주소 변경을 방지하기 위해서 만듬
    func textFieldIsUserInteraction(enable: Bool) {
        diaryView.placeTextField.isUserInteractionEnabled = enable
        diaryView.addressTextField.isUserInteractionEnabled = enable
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // binding 밸류 변화
        if textField == diaryView.placeTextField {
            viewModel.diaryModel.value.placeName = textField.text
        } else {
            viewModel.diaryModel.value.addressName = textField.text
        }
        diaryView.confirmButtonActivation()
    }
}

// MARK: - 텍스트뷰 델리게이트

extension DiaryViewController: UITextViewDelegate {
    
    // Placeholder 세팅
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.layer.borderWidth = 1
        
        if textView.text == diaryView.detailTextViewPlaceHolder {
            print(1)
            diaryView.detailTextView.text = nil
        }
        
        diaryView.detailTextView.textColor = .black
    }
    
    // Placeholder 세팅
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.layer.borderWidth = 0
        
        // 띄어쓰기, 즉 공백만 있을 경우 공백을 제거하고 플레이스 홀더를 나오게 만듬
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            diaryView.detailTextView.text = diaryView.detailTextViewPlaceHolder
            diaryView.detailTextView.textColor = .placeholderText
        }
        // binding 밸류 변화
        viewModel.diaryModel.value.detailText = textView.text
    }
    
    // 동적으로 텍스트뷰 크기 조정
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: diaryView.detailStackView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { constraint in
            // 3줄(80)보다 크고 5줄 (120)보다 작을 때 동작
            if estimatedSize.height >= 80 && estimatedSize.height <= 120 {
                constraint.constant = estimatedSize.height
            }
        }
        // 글자수 카운트
        diaryView.detailTextViewLetterCountLabel.text = "\(textView.text.count)"
    }
}

// MARK: - DiaryView Button Handler 델리게이트

extension DiaryViewController: DiaryViewDelegate {
    
    func saveOrEditButtonTapped(_ view: DiaryView) {
        self.view.endEditing(true)
        
        let buttonTitle = view.saveOrEditButton.titleLabel?.text
        switch buttonTitle {
        case "저장":
            print("Save button Tapped")
            // 데이터를 뷰모델로 저장 + 노티피케이션으로 ProfileVC로 전달
            viewModel.postNotificationWithModel(.saveButton)
            viewModel.saveToDatabase()
        case "수정":
            viewModel.postNotificationWithModel(.editButton)
            viewModel.editDatabase()
        default: break
        }
        
        self.dismiss(animated: false)
    }
    
    func closeButtonTapped(_ view: DiaryView) {
        print("Close button Tapped")
        self.dismiss(animated: false)
    }
}

// MARK: - 키보드 생성 시 뷰를 가리지 않도록 위치를 조정하는 프로토콜

extension DiaryViewController: KeyboardEvent {
    var transformView: UIView { return self.diaryView }
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



