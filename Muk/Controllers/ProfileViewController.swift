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
    
    lazy var collectionView: UICollectionView = {
        let layout = createBackgroundCollectionViewCompositionalLayout()
        let view = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        view.backgroundColor = HexCode.background.color
        view.isUserInteractionEnabled = true
        view.register(ProfileCell.self, forCellWithReuseIdentifier: ProfileCell.identifier)
        return view
    }()
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Int>!

    
    // MARK: - Life Cylces
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configUI()
        setupNavigationAppearance()
        setupCollectionView()
    }
    
    private func configUI() {
        
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
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileCell.identifier, for: indexPath) as? ProfileCell else { return nil }
            
            cell.delegate = self
            cell.backgroundColor = .lightGray
            return cell
        }
        
        var snapShot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapShot.appendSections([.main])
        snapShot.appendItems(Array(1...5))
        
        dataSource.apply(snapShot)
    }
    
    // 내부 콜렉션뷰 레이아웃 설정
    private func createBackgroundCollectionViewCompositionalLayout() -> UICollectionViewLayout {
        
        let sideInset: CGFloat = 20
        let itemInset: CGFloat = 10

        let layout = UICollectionViewCompositionalLayout { sectionIndext, layoutEnvironment in
            
            let itmeSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
            let itme = NSCollectionLayoutItem(layoutSize: itmeSize)
            itme.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: sideInset, bottom: itemInset, trailing: sideInset)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(0.4)
            )
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [itme])
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: itemInset, leading: 0, bottom: itemInset, trailing: 0)
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
        appearance.titlePositionAdjustment = UIOffset(horizontal: -CGFloat.greatestFiniteMagnitude,
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
    
    func imageTapped(_ cell: ProfileCell, sender: [Dictionary<String, String>]?) {
        print("ImageView Tapped")
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


