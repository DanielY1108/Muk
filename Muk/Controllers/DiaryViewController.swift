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
    
    private var selections = [String: PHPickerResult]()
    private var selectedAssetIdentifiers = [String]()
    
    
    // MARK: - Life Cycle
    
    override func loadView() {
        self.view = diaryView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageTapGasture()
        setupButtons()
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
    private func imageTapGasture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageViewHandler))
        
        if let lastImageView = diaryView.photoStackView.subviews.last {
            lastImageView.isUserInteractionEnabled = true
            lastImageView.addGestureRecognizer(tap)
        }
    }
    
    @objc func imageViewHandler() {
        presentPicker()
    }
    
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
        
        halfModalPresent(controller: imagePicker)
        self.present(imagePicker, animated: true)
    }
    
    // 이미지를 받아 이미지뷰 추가 작업
    private func addImageView(_ image: UIImage) {
        let imageView = UIFactory.createCircleImageView(size: 90)
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        
        diaryView.photoStackView.insertArrangedSubview(imageView, at: 0)
    }
    
    // 스택뷰 전체를 지우는 작업
    private func stackViewRemoveAllSubviews() {
        diaryView.photoStackView.subviews.forEach {
            if $0 != diaryView.plusImageView {
                $0.removeFromSuperview()
            }
        }
    }
    
    private func displayImage() {
        // 처음 스택뷰의 서브뷰들을 모두 제거함
        self.stackViewRemoveAllSubviews()

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
            // 선택한 이미지의 순서대로 정렬하여 스택뷰에 올리기
            for identifier in self.selectedAssetIdentifiers {
                guard let image = imagesDict[identifier] else { return }
                self.addImageView(image)
            }
        }
    }
    
    private func halfModalPresent(controller: UIViewController) {
        // iOS 15부터 사용 가능
        guard let sheet = controller.sheetPresentationController else { return }
        // 모달이 절반크기로 시작하고 확장이 가능
        sheet.detents = [.medium(), .large()]
        // true일 때 모달이 이전 컨트롤러와 크기가 같아질 때 스크롤 가능, false 하프 사이즈 부터 스크롤 사능
        sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        // 상단의 '-' 모양의 그랩바
        sheet.prefersGrabberVisible = true
    }
}

// MARK: - PHPickerViewControllerDelegate

extension DiaryViewController : PHPickerViewControllerDelegate {
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
