//
//  CustomAnnotation.swift
//  Muk
//
//  Created by JINSEOK on 2023/03/27.
//

import UIKit
import MapKit

enum AnnotaionProcess {
    case save
    case delete
}

final class CustomAnnotation: NSObject, MKAnnotation {
    
    @objc dynamic var coordinate: CLLocationCoordinate2D
    var image: UIImage?
    var identifier: UUID? = nil
    var process: AnnotaionProcess?
    
    init(coordinate: (Double, Double), image: UIImage, identifier: UUID) {
        self.coordinate = CLLocationCoordinate2D(latitude: coordinate.0, longitude: coordinate.1)
        self.image = image
        self.identifier = identifier
    }
}
