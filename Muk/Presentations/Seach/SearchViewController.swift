//
//  SearchViewController.swift
//  Muk
//
//  Created by JINSEOK on 2023/06/09.
//

import UIKit

class SearchViewController: UIViewController {
    
    // MARK: - Properites
    
    var searchListViewModel: SearchListViewModel!
    
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
        
        let label = UILabel()
        label.text = "팁: 주소를 같이 쓰면 더욱 정확해져요. (예: 맥도날드 강남)"
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = HexCode.selected.color

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
        guard let currentCoordinate = searchListViewModel.currentLoaction else {
            // 위치 정보가 없을 때, distance 없이 데이터 얻음
            SearchService.getLocation(name: searchText) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let location):
                    self.searchListViewModel.updateDocuments(location.documents)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                case .failure(let error):
                    print(error)
                }
            }
            return
        }

        // 위치 정보가 있을 때, distance 정보를 포함한 데이터를 얻음
        SearchService.getLocationWithCurrentLocation(name: searchText, x: currentCoordinate.longitude, y: currentCoordinate.latitude) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let location):
                self.searchListViewModel.updateDocuments(location.documents)

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            case .failure(let error):
                print(error)
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
        return searchListViewModel == nil ? 0 : searchListViewModel.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(SearchCell.self), for: indexPath) as? SearchCell else {
            fatalError("Failed Cell Load")
        }

        let searchViewModel = searchListViewModel.documentAtIndex(indexPath.row)
        
        cell.cellConfig(searchViewModel)
        
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let searchViewModel = searchListViewModel.documentAtIndex(indexPath.row)
        
        print(searchViewModel.latitude, searchViewModel.longitude)
        print(searchViewModel.distance)
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
