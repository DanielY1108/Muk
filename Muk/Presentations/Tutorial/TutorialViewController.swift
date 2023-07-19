//
//  TutorialViewController.swift
//  Muk
//
//  Created by JINSEOK on 2023/07/15.
//

import UIKit
import SnapKit

final class TutorialViewController: UIPageViewController {
    
    private var pages = [UIViewController]()
    private var initialPage = 0
    private var pageControrl: UIPageControl!
    private var skipButton: UIButton!
    private var nextButton: UIButton!
    
    private var pageControrlBottomContraint: Constraint?
    private var skipButtonTopContraint: Constraint?
    private var nextButtonTopContraint: Constraint?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setupDatabase()
        setupUI()
        setupLayout()
    }
    
    private func setupDatabase() {
        let page1 = TutorialContentsViewController(
            imageName: "page1",
            title: "나만의 지도 만들기",
            subTitle: """
                      맛집 및 추억을 하나 하나씩 저장하여,
                      나만의 지도를 만들어 보세요!
                      """
        )
        let page2 = TutorialContentsViewController(
            imageName: "page2",
            title: "플러스(+) 버튼",
            subTitle: """
                      중간에 위치한 플러스 버튼을 통해,
                      동작을 선택하고 추억을 작성할 수 있어요.
                      """
        )
        let page3 = TutorialContentsViewController(
            imageName: "page3",
            title: "검색하기",
            subTitle: "추억할 장소를 검색해 보세요."
        )
        let page4 = TutorialContentsViewController(
            imageName: "page4",
            title: "추억하기",
            subTitle: "사진 및 추억할 내용을 자유롭게 작성해보세요!"
        )
        let page5 = TutorialContentsViewController(
            imageName: "page5",
            title: "추억 리스트",
            subTitle: "이전에 작성한 추억들을 관리할 수 있어요."
        )
        let locationPermisstionPage = LocationPermissionViewController()
        locationPermisstionPage.delegate = self
        
        let pages = [page1, page2, page3, page4, page5, locationPermisstionPage]
        pages.forEach { self.pages.append($0) }
    }
    
    private func setupUI() {        
        self.dataSource = self
        // delegate를 통해 pageControl과 싱크를 맞춤
        self.delegate = self
        
        // UIPageViewController에서 처음 보여질 뷰컨트롤러 설정 (첫 번째 page)
        self.setViewControllers([pages[initialPage]], direction: .forward, animated: true)
        
        pageControrl = UIPageControl()
        pageControrl.numberOfPages = pages.count
        pageControrl.currentPageIndicatorTintColor = HexCode.selected.color
        pageControrl.pageIndicatorTintColor = HexCode.unselected.color
        pageControrl.backgroundColor = .clear
        pageControrl.addTarget(self, action: #selector(pageControlHandler), for: .valueChanged)
        
        var buttonConfig = UIButton.Configuration.plain()
        
        buttonConfig.baseForegroundColor = .gray
        buttonConfig.title = ButtonType.skip.rawValue
        skipButton = UIButton(configuration: buttonConfig)
        skipButton.clipsToBounds = true
        skipButton.layer.cornerRadius = 17
        skipButton.layer.borderWidth = 2
        skipButton.layer.borderColor = UIColor.gray.cgColor
        skipButton.addTarget(self, action: #selector(buttonHandler), for: .touchUpInside)
        
        buttonConfig.baseForegroundColor = HexCode.selected.color
        buttonConfig.title = ButtonType.next.rawValue
        nextButton = UIButton(configuration: buttonConfig)
        nextButton.clipsToBounds = true
        nextButton.layer.cornerRadius = 17
        nextButton.layer.borderWidth = 2
        nextButton.layer.borderColor = HexCode.selected.color.cgColor
        nextButton.addTarget(self, action: #selector(buttonHandler), for: .touchUpInside)
    }
    
    private func setupLayout() {
        view.addSubview(pageControrl)
        pageControrl.snp.makeConstraints {
            pageControrlBottomContraint = $0.bottom.equalTo(view.safeAreaLayoutGuide).constraint
            $0.centerX.equalToSuperview()
        }
        
        view.addSubview(skipButton)
        skipButton.snp.makeConstraints {
            skipButtonTopContraint = $0.top.equalTo(view.safeAreaLayoutGuide).offset(10).constraint
            $0.leading.equalTo(view).offset(20)
            $0.width.equalTo(80)
            $0.height.equalTo(34)
        }
        
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints {
            nextButtonTopContraint = $0.top.equalTo(view.safeAreaLayoutGuide).offset(10).constraint
            $0.trailing.equalTo(view).offset(-20)
            $0.width.equalTo(80)
            $0.height.equalTo(34)
        }
    }
}

// MARK: - DataSource

extension TutorialViewController: UIPageViewControllerDataSource {
    // 이전 뷰컨트롤러를 리턴 (우측 -> 좌측 슬라이드 제스쳐)
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currnetIndex = pages.firstIndex(of: viewController) else { return nil }
        
        guard currnetIndex > 0 else { return nil }
        return pages[currnetIndex - 1]
    }
    
    // 다음 보여질 뷰컨트롤러를 리턴 (좌측 -> 우측 슬라이드 제스쳐)
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currnetIndex = pages.firstIndex(of: viewController) else { return nil }

        guard currnetIndex < (pages.count - 1) else { return nil }
        return pages[currnetIndex + 1]
    }
}

// MARK: - Delegate

extension TutorialViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let currnetViewController = pageViewController.viewControllers,
              let currentIndex = pages.firstIndex(of: currnetViewController[0]) else { return }
        
        pageControrl.currentPage = currentIndex
        animateInterfaceLayoutIfNeeded()
    }
}

// MARK: - Actions

extension TutorialViewController: TutorialDelegate {
    // 페이지 컨트롤을 움직이면, 페이지를 표시 해줌
    @objc func pageControlHandler(_ sender: UIPageControl) {
        guard let currnetViewController = viewControllers?.first,
              let currnetIndex = pages.firstIndex(of: currnetViewController) else { return }
        
        // 코드의 순서 상 페이지의 인덱스보다 pageControl의 값이 먼저 변한다.
        // 그러므로, currentPage가 크면 오른쪽 방향, 작으면 왼쪽 방향으로 움직이게 설정해 줌
        let direction: UIPageViewController.NavigationDirection = (sender.currentPage > currnetIndex) ? .forward : .reverse
        self.setViewControllers([pages[sender.currentPage]], direction: direction, animated: true)
    }
    
    @objc func buttonHandler(_ sender: UIButton) {

        switch sender.titleLabel?.text {
        case ButtonType.skip.rawValue:
            let lastPageIndex = pages.count - 1
            goToSpecificPage(index: lastPageIndex, ofViewControllers: pages)
            pageControrl.currentPage = lastPageIndex
        case ButtonType.next.rawValue:
            goToNextPage()
            pageControrl.currentPage += 1
        default: break
        }
        animateInterfaceLayoutIfNeeded()
    }
    
    func startButtonTapped(_ viewController: UIViewController, sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - Extension

extension TutorialViewController {
    // 다음 페이지로 이동하기
    func goToNextPage() {
        // UIPageViewController에는
        guard let currentPage = viewControllers?[0],
              let nextPage = self.dataSource?.pageViewController(self, viewControllerAfter: currentPage) else { return }
        
        self.setViewControllers([nextPage], direction: .forward, animated: true)
    }
    
    // 이전 페이지로 이동하기
    func goToPreviousPage() {
        guard let currentPage = viewControllers?[0],
              let previousPage = self.dataSource?.pageViewController(self, viewControllerBefore: currentPage) else { return }
        
        self.setViewControllers([previousPage], direction: .reverse, animated: true)
    }
    
    // 특정 페이지로 이동하기
    func goToSpecificPage(index: Int, ofViewControllers pages: [UIViewController]) {
        setViewControllers([pages[index]], direction: .forward, animated: true, completion: nil)
    }
    
    private func animateInterfaceLayoutIfNeeded() {
        guard let currentViewController = viewControllers?[0] else { return }
        // 마지막 페이지일 때, 버튼 및 페이지 컨트롤 숨김
        if currentViewController == pages.last {
            hideInterface()
        } else {
            showInterface()
        }
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: .zero, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideInterface() {
        pageControrlBottomContraint?.update(offset: 100)
        skipButtonTopContraint?.update(offset: -100)
        nextButtonTopContraint?.update(offset: -100)
    }
    
    private func showInterface() {
        pageControrlBottomContraint?.update(offset: 0)
        skipButtonTopContraint?.update(offset: 10)
        nextButtonTopContraint?.update(offset: 10)
    }
}


fileprivate enum ButtonType: String {
    case skip = "Skip"
    case next = "Next"
}
