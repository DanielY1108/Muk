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

    // MARK: - Life Cycle
    override func loadView() {
        self.view = diaryView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageTapGasture()
    }

}

// MARK: - Setup
extension DiaryViewController {
    
    // DiaryView의 photoImageView를 클릭하면 동작하게 만듬
    private func imageTapGasture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        
        if let lastImageView = diaryView.photoImageViews.last {
            print(diaryView.photoImageViews.count)
            lastImageView.isUserInteractionEnabled = true
            lastImageView.addGestureRecognizer(tap)
        }
    }
    
    @objc func imageViewTapped() {
        var congig = PHPickerConfiguration()
        congig.filter = .images
        congig.selectionLimit = 3
        congig.selection = .ordered
        congig.preferredAssetRepresentationMode = .current
        
        let imagePicker = PHPickerViewController(configuration: congig)
        imagePicker.delegate = self

        // iOS 15부터 사용 가능
        if let sheet = imagePicker.sheetPresentationController {
            // 모달이 절반크기로 시작하고 확장이 가능
            sheet.detents = [.medium(), .large()]
            // true일 때 모달이 이전 컨트롤러와 크기가 같아질 때 스크롤 가능, false 하프 사이즈 부터 스크롤 사능
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            // 상단의 '-' 모양의 그랩바
            sheet.prefersGrabberVisible = true
        }
        self.present(imagePicker, animated: true)
    }
}

extension DiaryViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        self.dismiss(animated: true)
        
        for result in results {
            let itemProvider = result.itemProvider
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    DispatchQueue.main.async {
                        guard let selectImage = image as? UIImage else { return }
                        self.diaryView.addImage(selectImage)
                    }
                }
            }
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
