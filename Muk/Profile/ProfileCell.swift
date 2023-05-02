//
//  BackgroundCell.swift
//  Muk
//
//  Created by JINSEOK on 2023/04/13.
//

import UIKit

protocol ProfileCellDelegate: AnyObject {
    func editButtonTapped(_ cell: ProfileCell)
    func deleteButtonTapped(_ cell: ProfileCell)
    func showHideButtonTapped(_ cell: ProfileCell, button: UIButton)
    // TODO: - 나중에 데이터 받으면 다시 생각해보자(인덱스 값이랑 이미지가 필요)
    func imageTapped(_ cell: ProfileCell, sender: [UIImage]?)
}

final class ProfileCell: UICollectionViewCell {
    
    static let identifier = "BackgroundCell"
    
    weak var delegate: ProfileCellDelegate?
    
    // MARK: - Properties
    
    var photoArray: [UIImage]? {
        didSet {
            guard let photoArray = photoArray else { return }
            photoPageControl.numberOfPages = photoArray.count
            
            loadPhotos(photoArray)
        }
    }
    var photoImageViews = [UIImageView]() {
        didSet {
            scrollViewAddImageView()
        }
    }

    // 옵션 버튼 액션 설정
    private var optionButtonItmes: [UIAction] {
        
        let edit = UIAction(title: "수정하기") { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.editButtonTapped(self)
        }
        let delete = UIAction(title: "삭제하기",
                              attributes: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.deleteButtonTapped(self)
        }
        
        return [edit, delete]
    }
    
    // MARK: - Properties for UI
    
    lazy var optionButton: UIButton = {
        let button = UIButton(configuration: .plain())
        
        button.configurationUpdateHandler = { btn in
            
            var config = btn.configuration
            config?.image = UIImage(systemName: "ellipsis")
            
            btn.tintColor = .darkGray
            btn.configuration = config
        }
        button.addTarget(self, action: #selector(buttonHandler), for: .touchUpInside)
        return button
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()
    
    private lazy var photoScrollView: UIScrollView = {
        let view = UIScrollView()
        view.delegate = self
        view.backgroundColor = .darkGray
        return view
    }()
    
    private lazy var photoPageControl: UIPageControl = {
        let page = UIPageControl()
        page.currentPageIndicatorTintColor = .darkGray
        page.tintColor = .lightGray
        page.isUserInteractionEnabled = false
        return page
    }()
    
    private let placeImageView: UIImageView = {
        let view = UIImageView()
        // 크기와 색을변경 하기 위해 resized를 사용해 줌
        let resizeImage = UIImage(named: "location")?.resized(to: 15, tintColor: .darkGray)
        view.image = resizeImage
        return view
    }()
    
    let placeLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .darkGray
        return label
    }()
    
    private lazy var placeStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [placeImageView, placeLabel])
        view.axis = .horizontal
        view.spacing = 5
        return view
    }()
    
    let detailLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        return label
    }()
    
    lazy var showHideButton: UIButton = {
        var config = UIButton.Configuration.plain()
        
        var titleAttribute = AttributedString.init("Show")
        titleAttribute.font = .preferredFont(forTextStyle: .footnote)
        
        config.attributedTitle = titleAttribute
        config.baseForegroundColor = HexCode.selected.color
        
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(showHideButtonHandler), for: .touchUpInside)
       return button
    }()
    
    // MARK: - Setup Constants
    
    private let photoSize: CGFloat = 150
    private let sideInset: CGFloat = 30
    private let space: CGFloat = 10
    
    // MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configUI()
        configScrollView()
        setupMenu()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageViews.forEach { $0.image = nil }
    }
    
    // MARK: - Configuration
    
    func congigCell(_ model: DiaryModel) {
        photoArray = model.images
        dateLabel.text = model.date
        placeLabel.text = model.placeName
        detailLabel.text = model.detail
    }
    
    func hideButtonByNumberOfLines() {
        if detailLabel.lineCount < 3 {
            showHideButton.isHidden = true
            detailLabel.snp.updateConstraints {
                $0.trailing.equalToSuperview().inset(30)
            }
        } else {
            showHideButton.isHidden = false
            detailLabel.snp.updateConstraints {
                $0.trailing.equalToSuperview().inset(70)
            }
        }
    }
    
    private func configUI() {
        self.backgroundColor = HexCode.tabBarBackground.color
        layer.cornerRadius = 20
        layer.borderWidth = 1
        clipsToBounds = true
        
        setupLayout()
    }
    
    private func setupLayout() {
        self.addSubview(optionButton)
        optionButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(sideInset/2)
        }
        
        self.addSubview(dateLabel)
        dateLabel.snp.makeConstraints {
            $0.centerY.equalTo(optionButton)
            $0.leading.equalToSuperview().inset(sideInset)
        }
        
        self.addSubview(photoScrollView)
        photoScrollView.snp.makeConstraints {
            $0.top.equalTo(optionButton.snp.bottom).offset(space)
            $0.leading.trailing.equalToSuperview().inset(sideInset)
            $0.height.equalTo(photoSize)
        }
        
        self.addSubview(photoPageControl)
        photoPageControl.snp.makeConstraints {
            $0.top.equalTo(photoScrollView.snp.bottom).offset(space/2)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(space)
        }
        
        self.addSubview(placeStackView)
        placeStackView.snp.makeConstraints {
            $0.top.equalTo(photoPageControl.snp.bottom).offset(space)
            $0.leading.equalTo(photoScrollView)
        }
        
        self.addSubview(detailLabel)
        detailLabel.snp.makeConstraints {
            $0.top.equalTo(placeStackView.snp.bottom).offset(space)
            $0.leading.equalToSuperview().inset(sideInset)
            $0.trailing.equalToSuperview().inset(sideInset)
            $0.bottom.equalToSuperview().inset(space*2)
        }
        
        self.addSubview(showHideButton)
        showHideButton.snp.makeConstraints {
            $0.leading.equalTo(detailLabel.snp.trailing)
            $0.trailing.equalToSuperview().inset(space/2)
            $0.bottom.equalToSuperview().inset(space*3/2)
        }
    }
    
    // MARK: - Actions
    
    private func setupMenu() {
        let menu = UIMenu(children: self.optionButtonItmes)
        
        self.optionButton.menu = menu
        self.optionButton.showsMenuAsPrimaryAction = true
    }
    
    // 옵션 버튼 (정의 필요 없음)
    @objc func buttonHandler(_ sender: UIButton) {
        print("Option button Tapped")
    }
    
    @objc func showHideButtonHandler(_ sender: UIButton) {
        delegate?.showHideButtonTapped(self, button: sender)
    }
}


// MARK: - 스크롤뷰 델리게이트 & pagecontrol

extension ProfileCell: UIScrollViewDelegate {
    
    private func configScrollView() {
        
        photoScrollView.isPagingEnabled = true
        photoScrollView.showsHorizontalScrollIndicator = false
    }
    
    private func scrollViewAddImageView() {
        for (index, imageView) in photoImageViews.enumerated() {
            photoImageTapGesture(imageView)
            
            photoScrollView.addSubview(imageView)
            photoScrollView.contentSize = CGSize(width: (Int(self.bounds.width) - 60) * (index + 1), height: 150)
        }
    }
    
    private func loadPhotos(_ photos: [UIImage]) {
        
        for (index, photo) in photos.enumerated() {
            let photoImageView = UIImageView()
            photoImageView.contentMode = .scaleAspectFill
            photoImageView.image = photo
        
            photoImageView.frame.size.height = 150
            photoImageView.frame.size.width = self.bounds.size.width - 60
            photoImageView.frame.origin.x = CGFloat(index) * (self.bounds.size.width - 60)
            
            self.photoImageViews.append(photoImageView)
        }
    }
    
    // 스크롤뷰를 스크롤 시, 페이지 컨트롤 위치 이동
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.frame.size.width
        photoPageControl.currentPage = Int(page)
    }
    
    // TODO: - 이미지뷰와 클릭 상호작용으로 화면을 띄어주고 싶다.
    func photoImageTapGesture(_ imageView: UIImageView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageViewHandler))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)
    }
    
    @objc func imageViewHandler(_ sender: UITapGestureRecognizer) {
        delegate?.imageTapped(self, sender: self.photoArray)
    }
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




