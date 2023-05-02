//
//  CustomAnnotationView.swift
//  Muk
//
//  Created by JINSEOK on 2023/03/27.
//

import UIKit
import MapKit

final class CustomAnnotationView: MKAnnotationView {
    
    lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.layer.borderWidth = 1
        return view
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .orange
        label.textAlignment = .center
        return label
    }()
    
    lazy var customImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .lightGray
        return view
    }()
    
    lazy var stacView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, customImageView])
        view.spacing = 5
        view.axis = .vertical
        return view
    }()
    
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configUI() {
        self.addSubview(backgroundView)
        backgroundView.addSubview(stacView)
        
        backgroundView.snp.makeConstraints {
            $0.width.height.equalTo(70)
        }

        stacView.snp.makeConstraints {
            $0.edges.equalTo(backgroundView).inset(5)
        }
        
        self.canShowCallout = true
    }
    
    // Annotation도 재사용을 하므로 재사용전 값을 초기화 시켜서 다른 값이 들어가는 것을 방지
    override func prepareForReuse() {
        super.prepareForReuse()
        customImageView.image = nil
        titleLabel.text = nil
    }
    
    // annotation이 뷰에서 표시되기 전에 호출됩니다. (값을 정할 수 있다)
    override func prepareForDisplay() {
        super.prepareForDisplay()
        
        guard let annotation = annotation as? CustomAnnotation else { return }
        
        titleLabel.text = annotation.title
        
        guard let imageName = annotation.imageName,
              let image = UIImage(named: imageName) else { return }
        
        customImageView.image = image
        
        // 이미지의 크기 및 레이블의 사이즈가 변경될 수도 있으므로 레이아웃을 업데이트 한다.
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // MKAnnotationView 크기를 backgroundView 크기 만큼 정해주면 이미지를 클릭해도 동작한다.
        frame.size = CGSize(width: 70, height: 70)
        //
        centerOffset = CGPoint(x: 0, y: 35)

    }
}

// MARK: - PreView 읽기
import SwiftUI

#if DEBUG
struct PreView2: PreviewProvider {
    static var previews: some View {
        // 사용할 뷰 컨트롤러를 넣어주세요
        MapViewController()
            .toPreview()
    }
}
#endif
