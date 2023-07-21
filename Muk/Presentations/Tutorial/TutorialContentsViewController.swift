//
//  TutorialContentsViewController.swift
//  Muk
//
//  Created by JINSEOK on 2023/07/16.
//

import UIKit
import SnapKit

class TutorialContentsViewController: UIViewController {
    
    private var stackView: UIStackView!
    
    private var imageView = UIImageView()
    private var titleLabel = UILabel()
    private var subTitleLabel = UILabel()
    
    private var stackViewConstraint: Constraint?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupLayout()
    }
    
    init(imageName: String, title: String, subTitle: String) {
        super.init(nibName: nil, bundle: nil)
        imageView.image = UIImage(named: imageName)
        titleLabel.text = title
        subTitleLabel.text = subTitle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        view.backgroundColor = HexCode.tabBarBackground.color
        
        imageView.contentMode = .scaleAspectFit
        
        titleLabel.font = .preferredFont(forTextStyle: .title1)
        
        subTitleLabel.font = .preferredFont(forTextStyle: .body)
        subTitleLabel.textColor = .darkGray
        subTitleLabel.textAlignment = .center
        subTitleLabel.numberOfLines = 0
        
        self.stackView = UIStackView(arrangedSubviews: [titleLabel, subTitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.alignment = .center
    }
    
    private func setupLayout() {
        view.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-50)
            $0.width.equalTo(view).inset(20)
            $0.height.equalTo(view).multipliedBy(0.65)
        }
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            stackViewConstraint = $0.top.equalTo(imageView.snp.bottom).constraint
            $0.width.equalTo(view).inset(20)
        }
    }
    
    func updateLayout() {
        stackViewConstraint?.update(offset: -50)
    }
}

