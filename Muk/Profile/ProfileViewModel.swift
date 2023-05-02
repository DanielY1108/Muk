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
    
    // snapShot에 저장된 데이터를 리로드합니다. reconfigureItems로 업데이트를 시켜줘야 하지만 생성만으로도 업데이트가 되서 그냥 사용함.
    func updateCollectionViewSnapShot() {
        DispatchQueue.global(qos: .background).async {
            self.snapShot = NSDiffableDataSourceSnapshot<Section, DiaryModel>()
            self.snapShot.appendSections([.main])
            self.snapShot.appendItems(self.models.value ?? [])
            
            DispatchQueue.main.async {
                self.dataSource.apply(self.snapShot, animatingDifferences: true)
            }
        }
    }
    
    func deleteModel(at collectionView: UICollectionView, cell: ProfileCell) {
        guard let indexPaht = collectionView.indexPath(for: cell) else { return }
        self.removeData(indexPaht.row)
        self.updateCollectionViewSnapShot()
    }
    
    func loadModels() -> [DiaryModel]? {
        return models.value
    }
    
    func appendData(_ model: DiaryModel) {
        models.value?.append(model)
    }
    
    func removeData(_ index: Int) {
        models.value?.remove(at: index)
    }
    
  
}
