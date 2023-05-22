//
//  ProfileCollectionViewLayout.swift
//  Muk
//
//  Created by JINSEOK on 2023/05/12.
//

import UIKit

extension ProfileViewController {
    // 내부 콜렉션뷰 레이아웃 설정
    func createCollectionViewCompositionalLayout() -> UICollectionViewLayout {
        
        let sideInset: CGFloat = 20
        let itemInset: CGFloat = 10
        
        let size = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(300)
        )
        
        let layout = UICollectionViewCompositionalLayout { sectionIndext, layoutEnvironment in
            
            let itme = NSCollectionLayoutItem(layoutSize: size)
            // contentInsets 대신 edgeSpacing 사용해야 디버그창에 표시되는 레이아웃 에러를 해결가능
            itme.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: nil, top: .fixed(itemInset), trailing: nil, bottom: nil)
            
            let group = NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: [itme])
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: sideInset, bottom: sideInset, trailing: sideInset)
            return section
        }
        
        return layout
    }
}
