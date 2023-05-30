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
    var image: UIImage
    var identifier: UUID? = nil
    var process: AnnotaionProcess?
    
    override init() {
        self.coordinate = CLLocationCoordinate2D(latitude: 37, longitude: 127)
        self.image = UIImage(named: "emptyImage")!
    }
    
    init(coordinate: (Double, Double), image: UIImage, identifier: UUID, process: AnnotaionProcess) {
        self.coordinate = CLLocationCoordinate2D(latitude: coordinate.0, longitude: coordinate.1)
        self.image = image
        self.identifier = identifier
        self.process = process
    }
    
    init(databaseModel: RealmModel, process: AnnotaionProcess) {
        self.coordinate = CLLocationCoordinate2D(latitude: databaseModel.location.latitude,
                                                 longitude: databaseModel.location.longitude)
        self.identifier = databaseModel.identifier
        self.process = process
        
        let images = FileManager.loadImageFromDirectory(with: databaseModel.identifier)
        
        self.image = images?.first ?? UIImage(named: "emptyImage")!
    }
}
