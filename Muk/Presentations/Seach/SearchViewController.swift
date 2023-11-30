//
//  SearchViewController.swift
//  Muk
//
//  Created by JINSEOK on 2023/06/09.
//

import UIKit

final class SearchViewController: UIViewController {
    
    // MARK: - Properites
    
    var viewModels: SearchListViewModel!
    
    var searchController: UISearchController!
    var tableView: UITableView!
    
    // MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
}

// MARK: - Setup UI

extension SearchViewController {
    
    private func configUI() {
        view.backgroundColor = HexCode.background.color
        setupNavigationBarAppearance()
        setupSearchController()
        setupTableView()
        hideKeyBoardWhenTappedScreen()
    }
    
    func hideKeyBoardWhenTappedScreen() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        // 터치 시, 현재 뷰의 터치를 취소합니다. 기본값은 true이며, 상호작용이 필요하면 false로 처리
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapHandler() {
        searchController.searchBar.resignFirstResponder()
    }
    
    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = HexCode.background.color
        
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: HexCode.selected.color]
        appearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: HexCode.selected.color]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = HexCode.selected.color
        
        configNavigationBar()
    }
    
    private func configNavigationBar() {
        self.navigationItem.title = "검색"
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupSearchController() {
        self.searchController = UISearchController(searchResultsController: nil)
        self.navigationItem.searchController = searchController
        
        searchController.searchBar.delegate = self
        // 네이게이션 바의 back 버튼을 항상 보이기 위해 false
        searchController.hidesNavigationBarDuringPresentation = false
        // cancel 버튼 사용 안함
        searchController.automaticallyShowsCancelButton = false
        searchController.searchBar.placeholder = "장소를 검색해 주세요."
        
        let label = UIFactory.createTipLabel()
        
        searchController.searchBar.addSubview(label)
        label.snp.makeConstraints {
            $0.top.equalTo(searchController.searchBar.snp.bottom).offset(-5)
            $0.leading.equalTo(searchController.searchBar).offset(20)
        }
    }
    
    private func setupTableView() {
        self.tableView = UITableView()
        tableView.backgroundColor = HexCode.background.color
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            // 검색창 밑 TipLabel 의 크기를 고려해서 만들어 줌
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(SearchCell.self, forCellReuseIdentifier: NSStringFromClass(SearchCell.self))
    }
}

// MARK: - Search Delegate

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModels.getLocation(name: searchText) {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("end")
    }
}

// MARK: - TableView DataSource & Delegate

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels == nil ? 0 : viewModels.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(SearchCell.self), for: indexPath) as? SearchCell else {
            fatalError("Failed Cell Load")
        }
        
        let viewModel = viewModels.viewModelAtIndex(indexPath.row)
        
        cell.cellConfig(viewModel)
        
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        viewModels.goNextVC(indexPath.row, fromCurrentVC: self)
    }
}




// MARK: - PreView 읽기
import SwiftUI

#if DEBUG
struct PreView10: PreviewProvider {
    static var previews: some View {
        // 사용할 뷰 컨트롤러를 넣어주세요
        CustomTabBarController()
            .toPreview()
    }
}
#endif
