//
//  ProfileViewModel.swift
//  Muk
//
//  Created by JINSEOK on 2023/04/24.
//

import UIKit

final class ProfileViewModel {
    
    // MARK: - Properties
    
    var models: Observable<[DiaryModel]> = Observable([])
    
    var dataSource: UICollectionViewDiffableDataSource<Section, DiaryModel>!
    var snapShot: NSDiffableDataSourceSnapshot<Section, DiaryModel>!
    
    // MARK: - Methods
    
    func appendData(_ model: DiaryModel) {
        models.value?.append(model)
    }
    
    func hideButtonByNumberOfLines(_ cell: ProfileCell) {
        if cell.detailLabel.lineCount < 3 {
            cell.showHideButton.isHidden = true
            cell.detailLabel.snp.updateConstraints {
                $0.trailing.equalToSuperview().inset(30)
            }
        } else {
            cell.showHideButton.isHidden = false
            cell.detailLabel.snp.updateConstraints {
                $0.trailing.equalToSuperview().inset(70)
            }
        }
    }
    
    // snapShot에 저장된 데이터를 리로드합니다. reconfigureItems로 업데이트를 시켜줘야 하지만 생성만으로도 업데이트가 되서 그냥 사용함.
    func configCollectionViewSnapShot() {
        snapShot = NSDiffableDataSourceSnapshot<Section, DiaryModel>()
        snapShot.appendSections([.main])
        snapShot.appendItems(models.value ?? [])
        dataSource.apply(snapShot, animatingDifferences: false)
    }
}
