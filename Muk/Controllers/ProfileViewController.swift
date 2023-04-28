//
//  UserViewController.swift
//  Muk
//
//  Created by JINSEOK on 2023/03/13.
//

import UIKit

enum Section {
    case main
}

final class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    var models = [DiaryModel]()

    var viewModel = ProfileViewModel()
    
    lazy var collectionView: UICollectionView = {
        let layout = createBackgroundCollectionViewCompositionalLayout()
        let view = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        view.backgroundColor = HexCode.background.color
        view.isUserInteractionEnabled = true
        view.register(ProfileCell.self, forCellWithReuseIdentifier: ProfileCell.identifier)
        return view
    }()
    
    var dataSource: UICollectionViewDiffableDataSource<Section, DiaryModel>!

    
    // MARK: - Life Cylces
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configUI()
        setupNavigationAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupCollectionView()

    }
    
    private func configUI() {
        guard let tabBarController = tabBarController as? CustomTabBarController else { return }
        tabBarController.customDelegate = self
        
    }
}

// MARK: - 콜렉션 뷰

extension ProfileViewController {
    
    // 내부 콜렉션뷰 셋팅
    private func setupCollectionView() {
        self.view.addSubview(collectionView)
        
        configBackgroundCollectionViewDataSource()
    }

    // 내부 콜렉션뷰 dataSource 설정
    private func configBackgroundCollectionViewDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileCell.identifier, for: indexPath) as? ProfileCell else {
                fatalError("Failed Cell Load")
            }
            
            cell.delegate = self
            
            self.viewModel.models.bind { models in
                guard let images = models?[indexPath.row].images else { return }
                cell.photoArray = images
                cell.dateLabel.text = models?[indexPath.row].date
                cell.placeLabel.text = models?[indexPath.row].placeName
                cell.detailLabel.text = models?[indexPath.row].detail
            }
            
            return cell
        }
        
        var snapShot = NSDiffableDataSourceSnapshot<Section, DiaryModel>()
        snapShot.appendSections([.main])
        snapShot.appendItems(viewModel.models.value ?? [])
        dataSource.apply(snapShot)
    }
    
    // 내부 콜렉션뷰 레이아웃 설정
    private func createBackgroundCollectionViewCompositionalLayout() -> UICollectionViewLayout {
        
        let sideInset: CGFloat = 20
        let itemInset: CGFloat = 10
        
        let size = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(300)
        )

        let layout = UICollectionViewCompositionalLayout { sectionIndext, layoutEnvironment in
            
            let itme = NSCollectionLayoutItem(layoutSize: size)
            // contentInsets 대신 edgeSpacing 사용해야 디버그창에서 레이아웃 에러를 해결가능
            itme.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: nil, top: .fixed(itemInset), trailing: nil, bottom: nil)
   
            let group = NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: [itme])
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: sideInset, bottom: sideInset, trailing: sideInset)
            return section
        }
        
        return layout
    }

}


// MARK: - 네비게이션 컨트롤러 세팅

extension ProfileViewController {
    
    private func setupNavigationAppearance() {
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = HexCode.background.color
        appearance.titlePositionAdjustment = UIOffset(horizontal: -self.view.frame.midX,
                                                      vertical: 0)
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
                
        let titleLabel = UIFactory.createNavigationTitleLabel("Profile")
        navigationItem.titleView = titleLabel
    }
    
}


// MARK: - BackgroundCell Button Handler 델리게이트

extension ProfileViewController: ProfileCellDelegate {
  
    func editButtonTapped(_ cell: ProfileCell) {
        print("Edit Action")
    }
    
    func deleteButtonTapped(_ cell: ProfileCell) {
        print("Delete Action")
    }
    
    func imageTapped(_ cell: ProfileCell, sender: [UIImage]?) {
        print("ImageView Tapped")
    }
    
    // 콜렉션뷰 레이아웃 잡을 때, 크기를 동적으로 처리해놔서, 버튼을 통해 detailLabel의 줄수로 셀의 크기를 변경
    func showHideButtonTapped(_ cell: ProfileCell, button: UIButton) {
        print("show,Hide Button Tapped")

        // 아마도 타이틀을 AttributedString로 만들어줘서 currentTitle값이 nil인 듯 싶다.
        switch button.titleLabel?.text {
        case "Show":
            cell.detailLabel.numberOfLines = 0
            
            var titleAttribute = AttributedString.init("Hide")
            titleAttribute.font = .preferredFont(forTextStyle: .footnote)
            
            button.configuration?.attributedTitle = titleAttribute
            self.collectionView.reloadData()

        case "Hide":
            cell.detailLabel.numberOfLines = 2
            
            var titleAttribute = AttributedString.init("Show")
            titleAttribute.font = .preferredFont(forTextStyle: .footnote)

            button.configuration?.attributedTitle = titleAttribute
            self.collectionView.reloadData()

        default: break
        }
        
    }
}

// 커스텁 탭바에서 DiaryViewController로 접근하기 위해 델리게이트 사용
extension ProfileViewController: CustomTabBarControllerDelegate {
    func didSelectPopButton(viewController: CustomTabBarController, presentController: UIViewController) {
        guard let diaryViewController = presentController as? DiaryViewController else { return }
        diaryViewController.delegate = self
    }
}

// DiaryViewController에서 데이터를 받아와 Obsevable의 value를 업데이트 시켜줌
extension ProfileViewController: DiaryViewControllerDelegate {
    func loadData(viewController: DiaryViewController, model: DiaryModel) {
        models.append(model)
        viewModel.models.value = models
    }
}



// MARK: - PreView 읽기
import SwiftUI

#if DEBUG
struct PreView7: PreviewProvider {
    static var previews: some View {
        // 사용할 뷰 컨트롤러를 넣어주세요
        ProfileViewController()
            .toPreview()
    }
}
#endif


