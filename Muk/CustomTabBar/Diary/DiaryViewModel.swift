//
//  DiaryViewModel.swift
//  Muk
//
//  Created by JINSEOK on 2023/04/24.
//

import UIKit
import PhotosUI

final class DiaryViewModel {
    
    // MARK: - Properties
    
    var model: DiaryModel
    
    // MARK: - UI Properties
    
    // Identifier와 PHPickerResult로 만든 Dictionary (이미지 데이터를 저장하기 위해 만들어 줌)
    var selections = [String: PHPickerResult]()
    // 선택한 사진의 순서에 맞게 Identifier들을 배열로 저장해줄 겁니다.
    var selectedAssetIdentifiers = [String]()
    // 모든 이미지
    var images = [UIImage]()
    
    // MARK: - Initialize
    
    init() {
        self.model = DiaryModel(images: nil, date: nil, placeName: nil, locationName: nil, detail: nil)
    }
    
    convenience init(model: DiaryModel) {
        self.init()
        self.model = model
    }
    
    // MARK: - Method
    
    func saveData(on view: DiaryView) {
        guard let date = view.dateTextField.text,
              let placeName = view.placeTextField.text,
              let locationName = view.locationTextField.text,
              let detail = view.detailTextView.text else { return }
        
        let model = DiaryModel(images: images,
                               date: date,
                               placeName: placeName,
                               locationName: locationName,
                               detail: detail)
    
        NotificationNameIs.saveButton.postNotification(with: model)
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
            self.stackViewRemoveAllSubviews(in: view)
            // 기존에 저장된 이미지를 제거함 (이 로직이 이미지를 다 지우고 다시 읽어오는 것이므로 만약 이미지 수정 시
            // ProfileVC의 이미지가 선택한 이미지 + 수정한 이미지로 계속 추가되서 나타남)
            self.images = []
            
            // 선택한 이미지의 순서대로 정렬하여 스택뷰에 올리기
            for (index, identifier) in self.selectedAssetIdentifiers.enumerated() {
                guard let image = imagesDict[identifier] else { return }
                self.addImageView(on: view, image: image, index: index)
                
                // 밖에서 사용하기 위해서 만들어 줌
                self.images.insert(image, at: index)
            }
        }
    }
    
    // 이미지를 받아 이미지뷰 추가 작업, 버튼의 이미지를 항상 마지막에 위치하고 싶어 index를 받아와서 설정
    private func addImageView(on view: DiaryView, image: UIImage, index: Int) {
        let imageView = UIFactory.createCircleImageView(size: 90)
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        
        view.photoStackView.insertArrangedSubview(imageView, at: index)
    }
    
    // 스택뷰 전체를 지우는 작업
    func stackViewRemoveAllSubviews(in view: DiaryView) {
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
    
}
