//
//  venueAnnotation.swift
//  Pods
//
//  Created by Jon Miguel Jara on 9/25/17.
//
//

import Foundation
import MapKit

class venueAnnotation: NSObject, MKAnnotation {
    let name:String?
    let subtitle:String?
    let coordinate: CLLocationCoordinate2D
    
    init(name: String?, subtitle:String?, coordinate: CLLocationCoordinate2D)
    {
        self.name = name
        self.subtitle = subtitle
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String {
        return locationName
    }
}
