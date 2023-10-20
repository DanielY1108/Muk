//
//  SearchCell.swift
//  Muk
//
//  Created by JINSEOK on 2023/06/09.
//

import UIKit

final class SearchCell: UITableViewCell {
    
    private var placeNameLabel = UILabel()
    private var detailAddressLabel = UILabel()
    private var distanceLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        self.backgroundColor = HexCode.background.color
        
        placeNameLabel.font = .preferredFont(forTextStyle: .body)
        detailAddressLabel.font = .preferredFont(forTextStyle: .footnote)
        distanceLabel.font = .preferredFont(forTextStyle: .callout)
        
        let vStackView = UIStackView(arrangedSubviews: [placeNameLabel, detailAddressLabel])
        vStackView.axis = .vertical
        vStackView.spacing = 5
        
        let hStackView = UIStackView(arrangedSubviews: [vStackView, distanceLabel])
        hStackView.axis = .horizontal
        hStackView.distribution = .equalCentering
        
        contentView.addSubview(hStackView)
        hStackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(10)
            $0.trailing.leading.equalToSuperview().inset(20)
        }
    }
    
    func cellConfig(_ searchViewModel: SearchViewModel) {
        placeNameLabel.text = searchViewModel.document.placeName
        detailAddressLabel.text = searchViewModel.document.addressName
        
        guard let distance = Double(searchViewModel.document.distance) else { return }
        
        if distance >= 1000 {
            let convertMeterToKm = distance / 1000
            distanceLabel.text = String(format: "%.1fkm", convertMeterToKm)
        } else {
            distanceLabel.text = "\(searchViewModel.document.distance)m"
        }
    }
    
    
}
