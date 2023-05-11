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
    var image: UIImage?
    var title: String? = nil
    
    init(coordinate: (Double, Double), image: UIImage) {
        self.coordinate = CLLocationCoordinate2D(latitude: coordinate.0, longitude: coordinate.1)
        self.image = image
    }
}
