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
    
    private(set) var viewModel = ProfileViewModel()
    
    private(set) var collectionView: UICollectionView!
    
    // MARK: - Life Cylces
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reloadCollectionViewSnapShot()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.stopNotification()
        
        // 만약 텍스트뷰를 열어놨다면, 종료 시 닫아서 다시 킬 때 초기상태로 만듬
        guard let visibleCells = collectionView.visibleCells as? [ProfileCell] else { return }
        visibleCells.forEach { $0.showHideButton(isOn: false) }
    }
    
    // MARK: - Method
    
    private func configUI() {
        self.setupNavigationBarAppearance()
        self.setupCollectionView()
        viewModel.loadDatabase()
        viewModel.startNotificationWithCompletion()
        viewModel.binding()
    }
}

// MARK: - 콜렉션 뷰

extension ProfileViewController {
    
    // 내부 콜렉션뷰 셋팅
    private func setupCollectionView() {
        let layout = createCollectionViewCompositionalLayout()
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.backgroundColor = HexCode.background.color
        // cell의 버튼, 이미지 등 상호작용을 위해 true
        collectionView.isUserInteractionEnabled = true
        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: ProfileCell.identifier)
        self.view.addSubview(collectionView)
        
        // DataSource 생성 및 cell의 커스텀 델리게이트 생성
        viewModel.configDataSource(on: collectionView) { cell in
            cell.delegate = self
        }
    }
}


// MARK: - 네비게이션바 세팅

extension ProfileViewController {
    
    private func setupNavigationBarAppearance() {
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = HexCode.background.color
        // 제목을 좌측으로 이동시켜줌
        appearance.titlePositionAdjustment = UIOffset(horizontal: -self.view.frame.midX,
                                                      vertical: 0)
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        let titleLabel = UIFactory.createNavigationTitleLabel("Profile")
        navigationItem.titleView = titleLabel
    }
    
}


// MARK: - ProfileCell Button Handler 델리게이트

extension ProfileViewController: ProfileCellDelegate {
    
    func editButtonTapped(_ cell: ProfileCell) {
        let diaryVC = DiaryViewController()
        
        // 데이터 베이스에서 모델을 갖고 와서 넣어준다.
        guard let indexPath = collectionView.indexPath(for: cell),
              let diaryModels = viewModel.loadModels() else { return }
        
        let selectedDiaryModel = diaryModels[indexPath.row]
        diaryVC.viewModel.diaryModel.value = selectedDiaryModel
        
        diaryVC.diaryView.saveOrEditButton.configuration?.title = "수정"
        
        // 주소 텍스트 필드 수정 금지
        diaryVC.textFieldIsUserInteraction(enable: false)
        self.present(diaryVC, animated: true)
        
        print("Edit Action")
        
    }
    
    func deleteButtonTapped(_ cell: ProfileCell) {
        viewModel.deleteCell(cell, at: collectionView)
        print("Delete Action")
    }
    
    func imageTapped(_ cell: ProfileCell, sender: [UIImage]?) {
        print("ImageView Tapped")
    }
    
    // 콜렉션뷰 레이아웃 잡을 때, 크기를 동적으로 처리해놔서, 버튼을 통해 detailLabel의 줄수로 셀의 크기를 변경
    func showHideButtonTapped(_ cell: ProfileCell, button: UIButton) {
        print("show,Hide Button Tapped")
        
        cell.showHideButtonAction()
        viewModel.reloadCollectionViewSnapShot()
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


