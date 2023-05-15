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

    private let diaryView = DiaryView()
    // Identifier와 PHPickerResult로 만든 Dictionary (이미지 데이터를 저장하기 위해 만들어 줌)
    private(set) var selections = [String: PHPickerResult]()
    // 선택한 사진의 순서에 맞게 Identifier들을 배열로 저장해줄 겁니다.
    private(set) var selectedAssetIdentifiers = [String]()
    
    // MARK: - Life Cycle
    
    override func loadView() {
        self.view = diaryView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupKeyboardEvent()
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
        config.preselectedAssetIdentifiers = selectedAssetIdentifiers
        
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
    
    // 스택뷰 전체를 지우는 작업
    func stackViewRemoveAllSubviews(on view: DiaryView) {
        // 스크롤뷰의 콘텐츠 크기 조절
        photoContentViewInsetUpdate(view)
        
        view.photoStackView.subviews.forEach {
            if $0 != view.plusImageView {
                $0.removeFromSuperview()
            }
        }
    }
    
    // 스택뷰에 이미지를 추가함에 따라 스크롤뷰의 콘텐츠뷰의 크기를 증가시키는 메서드
    func photoContentViewInsetUpdate(_ view: DiaryView) {
        // 이미지가 추가될 때 마다 커지는 크기
        let imageSizeWithSpace = ((view.imageSize) / 2) + view.space
        var inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        // 현재 사진 갯수에 따라 크기를 키움
        for num in 0 ..< selections.count {
            inset.left = imageSizeWithSpace * CGFloat(num - 1)
        }
        
        // 이미지가 3개 이상일 때 contentInset 변경, 아니라면 초기화
        if selections.count >= 3 {
            view.photoScrollView.contentInset = inset
        } else {
            view.photoScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    // 이미지를 받아오는 작업 + 아래의 이미지뷰 추가 작업까지
    func displayImage(on view: DiaryView) {
        
        let dispatchGroup = DispatchGroup()
        // identifier와 이미지로 dictionary를 만듬 (selectedAssetIdentifiers의 순서에 따라 이미지를 받을 예정입니다.)
        var imagesDict = [String: UIImage]()
        
        for (identifier, result) in selections {
            
            dispatchGroup.enter()
            
            let itemProvider = result.itemProvider
            // 만약 itemProvider에서 UIImage로 로드가 가능하다면?
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                // 이미지의 url을 받아 다운샘플링하는 동작을 정의함 (비동기적으로 동작)
                itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, error in
                    guard let url = url else { return }
                    
                    let image = UIImage.downsampleImage(imageAt: url, to: CGSize(width: 1000, height: 1000))
                    
                    imagesDict[identifier] = image
                    dispatchGroup.leave()
                }
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
            for (index, identifier) in self.selectedAssetIdentifiers.enumerated() {
                guard let image = imagesDict[identifier] else { return }
                self.addImageView(on: view, image: image, index: index)
                
                // 밖에서 사용하기 위해서 만들어 줌
                self.viewModel.insertImage(image: image, at: index)
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
            stackViewRemoveAllSubviews(on: diaryView)
        } else {
            displayImage(on: diaryView)
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
        
        // 데이터를 뷰모델로 저장 + 노티피케이션으로 ProfileVC로 전달
        viewModel.configData(on: view)
        viewModel.postNotification()
        
        self.dismiss(animated: true)
    }
    
    func closeButtonTapped(_ view: DiaryView) {
        dismiss(animated: true)
        print("Close button Tapped")
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



