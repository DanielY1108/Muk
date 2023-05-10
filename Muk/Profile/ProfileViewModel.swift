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
    
    // snapShot을 업데이트 시킵니다. delete 동작도 이 메서드로 대체할 예정 (binding 으로 값이 변하면 자동 업데이트)
    func updateCollectionViewSnapShot() {
        DispatchQueue.global(qos: .background).async {
            var snapShot = NSDiffableDataSourceSnapshot<Section, DiaryModel>()
            snapShot.appendSections([.main])
            snapShot.appendItems(self.loadModels() ?? [])
            
            DispatchQueue.main.async {
                self.dataSource.apply(snapShot, animatingDifferences: true)
            }
        }
    }
    
    func reloadCollectionViewSnapShot() {
        var snapShot = dataSource.snapshot()
        let items = snapShot.itemIdentifiers
        // 기존의 셀을 유지하면서 아이템을 업데이트 한다. (prepareForReuse를 호출하지 않으므로 성능 상승)
        snapShot.reconfigureItems(items)
        DispatchQueue.main.async {
            self.dataSource.apply(snapShot, animatingDifferences: false)
        }
    }
    
//    func deleteCollectionViewSnapShot(at index: Int) {
//        var snapShot = dataSource.snapshot()
//        let item = snapShot.itemIdentifiers[index]
//        snapShot.deleteItems([item])
//        DispatchQueue.main.async {
//            self.dataSource.apply(snapShot, animatingDifferences: true)
//        }
//    }
    
    func deleteCell(_ cell: ProfileCell, at collectionView: UICollectionView) {
        guard let indexPaht = collectionView.indexPath(for: cell) else { return }
        self.removeData(indexPaht.row)
//        self.deleteCollectionViewSnapShot(at: indexPaht.row)
    }
    
    func loadModels() -> [DiaryModel]? {
        return models.value
    }
    
    func appendData(_ model: DiaryModel) {
        models.value?.insert(model, at: 0)
    }
    
    func removeData(_ index: Int) {
        models.value?.remove(at: index)
    }
}
