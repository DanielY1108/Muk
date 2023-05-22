//
//  EditDiaryViewController.swift
//  Muk
//
//  Created by JINSEOK on 2023/05/22.
//

import UIKit

final class EditDiaryViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    
    }

}




// MARK: - PreView 읽기
import SwiftUI

#if DEBUG
struct PreView9: PreviewProvider {
    static var previews: some View {
        // 사용할 뷰 컨트롤러를 넣어주세요
        ProfileViewController()
            .toPreview()
    }
}
#endif


