//
//  BackgroundCell.swift
//  Muk
//
//  Created by JINSEOK on 2023/04/13.
//

import UIKit

class BackgroundCell: UICollectionViewCell {
    
    static let identifier = "BackgroundCell"
    
    // MARK: - Properties
    
    let photo1 = ["image" : "globe"]
    let photo2 = ["image" : "user"]
    let photo3 = ["image" : "location"]
    
    var photoArray: [Dictionary<String, String>]! {
        didSet {
            photoPageControl.numberOfPages =  photoArray.count
        }
    }
    
    // MARK: - Properties for UI
    
    let optionButton: UIButton = {
        let button = UIButton(configuration: .plain())
        
        button.configurationUpdateHandler = { btn in
            
            var config = btn.configuration
            config?.image = UIImage(systemName: "ellipsis")
            
            btn.tintColor = .darkGray
            btn.configuration = config
        }
        
        return button
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.text = "2023년 04월 15일"
        return label
    }()
    
    lazy var photoScrollView: UIScrollView = {
        let view = UIScrollView()
        view.delegate = self
        view.backgroundColor = .darkGray
        return view
    }()
    
    lazy var photoPageControl: UIPageControl = {
       let page = UIPageControl()
        page.currentPageIndicatorTintColor = .darkGray
        page.isUserInteractionEnabled = false
        return page
    }()
        
    lazy var locationStackView: UIStackView = {
        
        let locaionImageView: UIImageView = {
            let view = UIImageView()
            let resizeImage = UIImage(named: "location")?.resized(to: 16, tintColor: .darkGray)
            view.image = resizeImage
            return view
        }()
        
        let loactionLabel: UILabel = {
            let label = UILabel()
            label.font = .preferredFont(forTextStyle: .footnote)
            label.textColor = .darkGray
            label.text = "베이다드"
            return label
        }()
        
       let view = UIStackView(arrangedSubviews: [locaionImageView, loactionLabel])
        view.axis = .horizontal
        view.spacing = 5
        
        return view
    }()
    
    let detailLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.text = """
                     기본 텍스트는 2줄
                     입니다. 더이상 입력 불가.더이상 입력 불가.더이상 입력 불가
                     """
        return label
    }()
        
    
    // MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configUI()
        configScrollView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Configuration
    
    private func configUI() {
        layer.cornerRadius = 20
        clipsToBounds = true
        
        self.addSubview(optionButton)
        optionButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(15)
        }
        
        self.addSubview(dateLabel)
        dateLabel.snp.makeConstraints {
            $0.centerY.equalTo(optionButton)
            $0.leading.equalToSuperview().offset(30)
        }
        
        self.addSubview(photoScrollView)
        photoScrollView.snp.makeConstraints {
            $0.top.equalTo(optionButton.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(150)
        }
        
        self.addSubview(photoPageControl)
        photoPageControl.snp.makeConstraints {
            $0.top.equalTo(photoScrollView.snp.bottom).offset(5)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(20)
        }

        self.addSubview(locationStackView)
        locationStackView.snp.makeConstraints {
            $0.top.equalTo(photoPageControl.snp.bottom).offset(5)
            $0.leading.equalTo(photoScrollView)
        }
        
        self.addSubview(detailLabel)
        detailLabel.snp.makeConstraints {
            $0.top.equalTo(locationStackView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.height.lessThanOrEqualToSuperview().offset(-20)
        }
    }
}


// MARK: - 스크롤뷰 델리게이트 & pagecontrol

extension BackgroundCell: UIScrollViewDelegate {
    
    
    private func configScrollView() {
        
        // 사진 더미 데이터
        photoArray = [photo1, photo2, photo3]
        
        photoScrollView.isPagingEnabled = true
        photoScrollView.showsHorizontalScrollIndicator = false
        photoScrollView.contentSize = CGSize(width: (self.bounds.width - 60) * 3, height: 150)
        
        loadPhotos()
    }
    
    private func loadPhotos() {
        
        for (index, photo) in photoArray.enumerated() {
            let photoImageView = UIImageView()
            photoImageView.backgroundColor = .blue
            photoImageView.contentMode = .scaleAspectFit
            photoImageView.image = UIImage(named: photo["image"]!)
            
            photoScrollView.addSubview(photoImageView)
            photoImageView.frame.size.height = 150
            photoImageView.frame.size.width = self.bounds.size.width - 60
            photoImageView.frame.origin.x = CGFloat(index) * (self.bounds.size.width - 60)
        }
    }
    
    // 스크롤뷰를 스크롤 시, 페이지 컨트롤 위치 이동
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.frame.size.width
        photoPageControl.currentPage = Int(page)
    }
    
    // TODO: - 이미지뷰와 클릭 상호작용으로 화면을 띄어주고 싶다.

}



// MARK: - PreView 읽기
import SwiftUI

#if DEBUG
struct PreView8: PreviewProvider {
    static var previews: some View {
        // 사용할 뷰 컨트롤러를 넣어주세요
        ProfileViewController()
            .toPreview()
    }
}
#endif




