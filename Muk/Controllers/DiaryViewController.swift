//
//  DiaryViewController.swift
//  Muk
//
//  Created by JINSEOK on 2023/03/30.
//

import UIKit

class DiaryViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
    
        halfModalPresentation()
    }
    
    
    // iOS 15부터 사용 가능
    func halfModalPresentation() {
        
        if let sheet = self.sheetPresentationController {
            // 모달이 절반크기로 시작하고 확장이 가능
            sheet.detents = [.medium(), .large()]
            // true일 때 모달이 이전 컨트롤러와 크기가 같아질 때 스크롤 가능, false 하프 사이즈 부터 스크롤 사능
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            // 상단의 '-' 모양의 그랩바
            sheet.prefersGrabberVisible = true
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
