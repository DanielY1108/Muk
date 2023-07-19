//
//  LocationPermissionViewController.swift
//  Muk
//
//  Created by JINSEOK on 2023/07/19.
//

import UIKit

protocol TutorialDelegate {
    func startButtonTapped(_ viewController: UIViewController, sender: UIButton)
}

class LocationPermissionViewController: UIViewController {
    
    var delegate: TutorialDelegate?
    
    private var infoStackView: UIStackView!
    private var imageView = UIImageView()
    private var titleLabel = UILabel()
    private var subTitleLabel = UILabel()
    
    private var buttonStackView: UIStackView!
    private var startButton: UIButton!
    private var descriptionLabel = UILabel()
    private var checkBoxButton: UIButton!
    
    private var totalStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupLayout()
        setupData()
    }
    
    private func setupUI() {
        view.backgroundColor = HexCode.tabBarBackground.color
        
        imageView.contentMode = .scaleAspectFit
        
        titleLabel.font = .preferredFont(forTextStyle: .title1)
        
        subTitleLabel.font = .preferredFont(forTextStyle: .body)
        subTitleLabel.textColor = .darkGray
        subTitleLabel.textAlignment = .center
        subTitleLabel.numberOfLines = 0
        
        self.infoStackView = UIStackView(arrangedSubviews: [imageView, titleLabel, subTitleLabel])
        infoStackView.axis = .vertical
        infoStackView.spacing = 20
        infoStackView.alignment = .center
        
        var startButtonConfig = UIButton.Configuration.filled()
        var titleAttribute = AttributedString(stringLiteral: "시작하기")
        titleAttribute.font = .preferredFont(forTextStyle: .title2)
        startButtonConfig.attributedTitle = titleAttribute
        startButtonConfig.baseBackgroundColor = HexCode.unselected.color
        startButtonConfig.baseForegroundColor = HexCode.selected.color
        startButton = UIButton(configuration: startButtonConfig)
        startButton.addTarget(self, action: #selector(buttonHandler), for: .touchUpInside)
        
        descriptionLabel.font = .preferredFont(forTextStyle: .footnote)
        descriptionLabel.textColor = .darkGray
        descriptionLabel.textAlignment = .center
        
        var checkBoxButtonConfig = UIButton.Configuration.plain()
        checkBoxButtonConfig.image = fisrtCheckBoxImage()
        checkBoxButtonConfig.imagePadding = 5
        checkBoxButtonConfig.title = "다음부터 보지 않기"
        checkBoxButtonConfig.baseForegroundColor = HexCode.selected.color
        checkBoxButton = UIButton(configuration: checkBoxButtonConfig)
        checkBoxButton.addTarget(self, action: #selector(checkBoxButtonHandler), for: .touchUpInside)
        
        buttonStackView = UIStackView(arrangedSubviews: [startButton, descriptionLabel, checkBoxButton])
        buttonStackView.axis = .vertical
        buttonStackView.spacing = 15
        buttonStackView.alignment = .center
        
        totalStackView = UIStackView(arrangedSubviews: [infoStackView, buttonStackView])
        totalStackView.axis = .vertical
        totalStackView.spacing = 100
        totalStackView.alignment = .center
    }
    
    private func setupLayout() {
        imageView.snp.makeConstraints {
            $0.width.height.equalTo(100)
        }
        
        startButton.snp.makeConstraints {
            $0.width.equalToSuperview().inset(60)
            $0.height.equalTo(50)
        }
        
        view.addSubview(totalStackView)
        totalStackView.snp.makeConstraints {
            $0.center.equalTo(view.safeAreaLayoutGuide)
            $0.width.equalTo(view).inset(20)
        }
    }
    
    private func setupData() {
        let image = UIImage(named: "location")
        let retintImage = image?.retinted(HexCode.selected.color)
        imageView.image = retintImage
        titleLabel.text = "위치 권한 요청"
        subTitleLabel.text = """
                             사용자가 위치 접근을 허용하면, 위치를 사용하여 사용자 주변 장소 찾기 및 현재 위치를 기준으로 새로운 '추억'을 생성할 수 있습니다.
                             
                             원활한 앱 사용을 위해, 위치 권한 설정을
                             '항상 허용'으로 설정해 주세요.
                             """
        descriptionLabel.text = "나중에 언제든, 앱 설정에서 위치 권한을 변경할 수 있습니다."
    }
    
    @objc func buttonHandler(_ sender: UIButton) {
        delegate?.startButtonTapped(self, sender: sender)
    }
    
    @objc func checkBoxButtonHandler(_ sender: UIButton) {
        let userDefaults = UserDefaults.standard
        var isCheckedButton = userDefaults.bool(forKey: "tutorial")
        
        isCheckedButton.toggle()
        
        if isCheckedButton {
            checkBoxButton.configurationUpdateHandler = { button in
                button.configuration?.image = CheckButton.check.imgae
            }
            UserDefaults.standard.set(true, forKey: "tutorial")
        } else {
            checkBoxButton.configurationUpdateHandler = { button in
                button.configuration?.image = CheckButton.empty.imgae
            }
            UserDefaults.standard.set(false, forKey: "tutorial")
        }
    }
    
    private func fisrtCheckBoxImage() -> UIImage {
        let userDefaults = UserDefaults.standard
        var isCheckedButton = userDefaults.bool(forKey: "tutorial")
        
        if isCheckedButton {
            return CheckButton.check.imgae
        } else {
            return CheckButton.empty.imgae
        }
    }
}

fileprivate enum CheckButton {
    case empty
    case check
    
    var imgae: UIImage {
        switch self {
        case .empty:
            let image = UIImage(named: "checkBox")
            let resizeImage = image?.resized(to: 22, tintColor: HexCode.selected.color)
            return resizeImage!
        case .check:
            let image = UIImage(named: "checkBox-correct")
            let resizeImage = image?.resized(to: 22, tintColor: HexCode.selected.color)
            return resizeImage!
        }
    }
}

// MARK: - PreView 읽기
import SwiftUI

#if DEBUG
struct PreView123: PreviewProvider {
    static var previews: some View {
        // 사용할 뷰 컨트롤러를 넣어주세요
        LocationPermissionViewController()
            .toPreview()
    }
}
#endif
