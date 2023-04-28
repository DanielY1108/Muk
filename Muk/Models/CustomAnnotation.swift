//
//  CustomAnnotation.swift
//  Muk
//
//  Created by JINSEOK on 2023/03/27.
//

import UIKit
import MapKit

final class CustomAnnotation: NSObject, MKAnnotation {
    
    @objc dynamic var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var imageName: String?
    
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
    }
}
