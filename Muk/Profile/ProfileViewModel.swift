//
//  ProfileViewModel.swift
//  Muk
//
//  Created by JINSEOK on 2023/04/24.
//

import UIKit

final class ProfileViewModel {
    
    // MARK: - Properties
    
    private(set) var models: Observable<[DiaryViewModel]> = Observable([])
    
    private(set) var dataSource: UICollectionViewDiffableDataSource<Section, DiaryViewModel>!
    private(set) var snapShot: NSDiffableDataSourceSnapshot<Section, DiaryViewModel>!

    // MARK: - Methods
        
    func loadModels() -> [DiaryViewModel]? {
        return models.value
    }
    
    // insert로 하면 최신이 위로 올라가게 된다.
    func appendModel(_ model: DiaryViewModel) {
        models.value?.insert(model, at: 0)
    }
    
    func removeData(_ index: Int) {
        models.value?.remove(at: index)
    }
    
    func deleteCell(_ cell: ProfileCell, at collectionView: UICollectionView) {
        guard let indexPaht = collectionView.indexPath(for: cell) else { return }
        self.removeData(indexPaht.row)
//        self.deleteCollectionViewSnapShot(at: indexPaht.row)
    }
    
}

// MARK: - CollectionView DataSource Methods

extension ProfileViewModel {
    
    // 내부 콜렉션뷰 dataSource 설정
    func configDataSource(on collectionView: UICollectionView, completion: @escaping (ProfileCell) -> Void) {
        self.dataSource = UICollectionViewDiffableDataSource<Section, DiaryViewModel>(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileCell.identifier, for: indexPath) as? ProfileCell else {
                fatalError("Failed Cell Load")
            }
            completion(cell)

            guard let models = self.loadModels() else {
                fatalError("Failed Load Models")
            }
            
            let model = models[indexPath.row]
            
            cell.configCell(model)
            cell.hideButtonByNumberOfLines()

            return cell
        }
    }
    
    // snapShot을 업데이트 시킵니다. delete 동작도 이 메서드로 대체할 예정 (binding 으로 값이 변하면 자동 업데이트)
    func updateCollectionViewSnapShot() {
        DispatchQueue.global(qos: .background).async {
            var snapShot = NSDiffableDataSourceSnapshot<Section, DiaryViewModel>()
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
}

// MARK: - Notification Methods

extension ProfileViewModel {
    
    func setupNotification() {
        NotificationNameIs.saveButton.startNotification { [weak self] notification in
            guard let self = self,
                  let diaryViewModel = notification.object as? DiaryViewModel else { return }
            
            self.appendModel(diaryViewModel)
        }
    }
    
    func stopNotification() {
        NotificationNameIs.saveButton.stopNotification()
    }
}
