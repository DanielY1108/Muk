//
//  MapPopupView.swift
//  Muk
//
//  Created by JINSEOK on 12/12/23.
//

import UIKit

final class MapPopupView: UIView {
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.contentMode = .scaleToFill
        return view
    }()
    
    let placeLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .systemBackground
        label.textAlignment = .center
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .systemBackground
        label.textAlignment = .center
        return label
    }()
    
    let detailLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.9
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .systemBackground
        label.textAlignment = .center
        return label
    }()
    
    let goToProfileButton: UIButton = {
        var buttonConfig = UIButton.Configuration.filled()
        buttonConfig.baseBackgroundColor = HexCode.unselected.color
        buttonConfig.baseForegroundColor = HexCode.selected.color
        buttonConfig.title = "자세히보기"
        
        let button = UIButton(configuration: buttonConfig)
        return button
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = HexCode.tabBarBackground.color
        layer.borderWidth = 1
        layer.cornerRadius = 10
        clipsToBounds = true
    }
    
    private func setupLayout() {
        let screen = UIScreen.main.bounds

        imageView.snp.makeConstraints {
            $0.width.equalTo(screen.width/2.5)
        }
        
        placeLabel.snp.makeConstraints {
            $0.height.equalTo(20)
        }
        dateLabel.snp.makeConstraints {
            $0.height.equalTo(15)
        }
        goToProfileButton.snp.makeConstraints {
            $0.height.equalTo(30)
        }
        
        let lineView = UIView()
        lineView.backgroundColor = HexCode.selected.color
        lineView.snp.makeConstraints {
            $0.height.equalTo(1)
        }

        let vStack = UIStackView(arrangedSubviews: [placeLabel, lineView, dateLabel, lineView, detailLabel, goToProfileButton])
        vStack.spacing = 8
        vStack.axis = .vertical
        
        let hStack = UIStackView(arrangedSubviews: [imageView, vStack])
        hStack.spacing = 10
        hStack.axis = .horizontal
        
        addSubview(hStack)
        hStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
        }
    }
    
    func initialSetupLayout(_ currentView: UIView) {
        snp.makeConstraints {
            $0.height.equalTo(currentView.bounds.height/4)
            $0.leading.trailing.equalTo(currentView).inset(10)
            $0.bottom.equalTo(currentView).offset(currentView.bounds.height/4)
        }
    }
}



// MARK: - PreView 읽기
import SwiftUI

#if DEBUG
struct PreView12: PreviewProvider {
    static var previews: some View {
        // 사용할 뷰 컨트롤러를 넣어주세요
        MapViewController()
            .toPreview()
    }
}
#endif
