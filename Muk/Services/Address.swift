//
//  Address.swift
//  Muk
//
//  Created by JINSEOK on 2023/06/23.
//

import Foundation


struct Address: Codable {
    let documents: [ADoument]
}

struct ADoument: Codable {
    let addressName: String
    let longitude: Double
    let latitude: Double
    
    enum CodingKeys: String, CodingKey {
        case addressName = "address_name"
        case longitude = "x"
        case latitude = "y"
    }
}
