//
//  ProfileViewModel.swift
//  Muk
//
//  Created by JINSEOK on 2023/04/24.
//

import UIKit

final class ProfileViewModel {
    
    // MARK: - Properties
    
    private(set) var diaryModels: Observable<[DiaryModel]> = Observable([])
    
    private(set) var dataSource: UICollectionViewDiffableDataSource<Section, DiaryModel>!
    private(set) var snapShot: NSDiffableDataSourceSnapshot<Section, DiaryModel>!
    
    // MARK: - Methods
    
    func loadModels() -> [DiaryModel]? {
        return diaryModels.value
    }
    
    // insert로 하면 최신이 위로 올라가게 된다.
    func appendModel(_ model: DiaryModel) {
        diaryModels.value.insert(model, at: 0)
    }
    
    private func removeData(_ index: Int) {
        diaryModels.value.remove(at: index)
    }
    
    func deleteCell(_ cell: ProfileCell, at collectionView: UICollectionView) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        let uuid = diaryModels.value[indexPath.row].identifier
        // 노티피케이션을 통해 MapVC로 UUID전달
        NotificationNameIs.deleteBtton.postNotification(with: uuid)
        
        self.removeData(indexPath.row)
        self.deleteDataInDatabase(identifier: uuid)
    }
    
    
    func binding() {
        // 바인딩
        diaryModels.bind { [weak self] models in
            guard let self = self else { return }
            
            self.updateCollectionViewSnapShot()
        }
    }
}

// MARK: - CollectionView DataSource Methods

extension ProfileViewModel {
    
    // 내부 콜렉션뷰 dataSource 설정
    func configDataSource(on collectionView: UICollectionView, completion: @escaping (ProfileCell) -> Void) {
        self.dataSource = UICollectionViewDiffableDataSource<Section, DiaryModel>(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            
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
}

// MARK: - Notification Methods

extension ProfileViewModel {
    
    func startNotificationWithCompletion() {
        NotificationNameIs.saveButton.startNotification { [weak self] notification in
            guard let self = self,
                  let diaryModel = notification.object as? DiaryModel else { return }
            
            self.appendModel(diaryModel)
        }
    }
    
    func stopNotification() {
        NotificationNameIs.saveButton.stopNotification()
    }
}

// MARK: - Database

extension ProfileViewModel {
    func loadDatabase() {
        // 일단은 날짜 순으로 정렬 시킴
        let databaseModels = RealmManager.shared.sort(RealmModel.self, by: "date", ascending: false)
        let diaryModels = Array(databaseModels.map { DiaryModel(dataBaseModel: $0) })
        
        self.diaryModels.value = diaryModels
    }
    
    private func deleteDataInDatabase(identifier: UUID) {
        // Realm 데이터 삭제 (선택한 식별자가 같으면 제거)
        let databaseModels = RealmManager.shared.load(RealmModel.self)
        let selectedDatabase = Array(databaseModels.filter { $0.identifier == identifier }).first!
        RealmManager.shared.delete(selectedDatabase)
        
        // 이미지 삭제
        FileManager.deleteImageFromDirectory(with: identifier)
    }
}
