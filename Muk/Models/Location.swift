//
//  Location.swift
//  Muk
//
//  Created by JINSEOK on 2023/03/29.
//

import Foundation

struct Location: Codable {
    let documents: [Document]
}

struct Document: Codable {
    let addressName: String
    let roadAddressName: String
    let placeName: String
    let placeURL: String
    let x, y: String
    
    enum CodingKeys: String, CodingKey {
        case addressName = "address_name"
        case roadAddressName = "road_address_name"
        case placeName = "place_name"
        case placeURL = "place_url"
        case x, y
    }
}
