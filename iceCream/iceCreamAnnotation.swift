//
//  iceCreamAnnotation.swift
//  iceCream
//
//  Created by Jon Miguel Jara on 9/25/17.
//  Copyright © 2017 Jon Miguel Jara. All rights reserved.
//

import Foundation
import MapKit

class iceCreamAnnotation: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
        
        super.init()
    }
    
    
    func mapItem() -> MKMapItem {
        let placemark = MKPlacemark(coordinate: coordinate)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        
        return mapItem
    }

    
}
