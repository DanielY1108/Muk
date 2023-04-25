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
    
    private var viewModel = DiaryViewModel()
    
    // MARK: - Life Cycle
    
    override func loadView() {
        self.view = diaryView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    deinit {
        print("다이어리 컨트롤러 해제")
    }
}

// MARK: - Setup

extension DiaryViewController {
    
    private func saveData() {
        guard let date = diaryView.dateTextField.text,
              let placeName = diaryView.placeTextField.text,
              let locationName = diaryView.locationTextField.text,
              let detail = diaryView.detailTextView.text else { return }
        
        let model = DiaryModel(images: viewModel.images,
                               date: date,
                               placeName: placeName,
                               locationName: locationName,
                               detail: detail)
        
        viewModel = DiaryViewModel(model: model)
        delegate?.loadData(viewController: self, model: model)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func setupUI() {
        diaryView.delegate = self
        diaryView.photoScrollView.delegate = self

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
        presentPicker()
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
        config.preselectedAssetIdentifiers = viewModel.selectedAssetIdentifiers
        
        // 만들어준 Configuration를 사용해 PHPicker 컨트롤러 객체 생성
        let imagePicker = PHPickerViewController(configuration: config)
        imagePicker.delegate = self
        
        UIFactory.halfModalPresent(controller: imagePicker)
        self.present(imagePicker, animated: true)
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
            newSelections[identifier] = viewModel.selections[identifier] ?? result
        }
        
        // selections에 새로 만들어진 newSelection을 넣어줍시다.
        viewModel.selections = newSelections
        // Picker에서 선택한 이미지의 Identifier들을 저장 (assetIdentifier은 옵셔널 값이라서 compactMap 받음)
        // 위의 PHPickerConfiguration에서 사용하기 위해서 입니다.
        viewModel.selectedAssetIdentifiers = results.compactMap { $0.assetIdentifier }
        
        if viewModel.selections.isEmpty {
            viewModel.stackViewRemoveAllSubviews(in: diaryView)
        } else {
            viewModel.displayImage(on: diaryView)
        }
    }
}

// MARK: - DiaryView의 스크롤뷰 델리게이트

extension DiaryViewController: UIScrollViewDelegate {    
    // 콘텐츠뷰의 크기가 변할 때 마다 스크롤뷰의 위치를 이동 시켜줌, 스크롤뷰에서 보이는 화면을 마지막 버튼으로 이동
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        let x = scrollView.adjustedContentInset.left
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }
    
}

// MARK: - DiaryView Button Handler 델리게이트

extension DiaryViewController: DiaryViewDelegate {
    
    func saveButtonTapped(_ view: DiaryView) {
        print("Save button Tapped")
        saveData()
        
        self.dismiss(animated: true)
    }
    
    func closeButtonTapped(_ view: DiaryView) {
        dismiss(animated: true)
        print("Close button Tapped")
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



