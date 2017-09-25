//
//  iceCreamAnnotation.swift
//  iceCream
//
//  Created by Jon Miguel Jara on 9/23/17.
//  Copyright © 2017 Jon Miguel Jara. All rights reserved.
//

import Foundation


import MapKit

class CoffeeAnnotation: NSObject, MKAnnotation
{
    let title:String?
    let subtitle:String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String?, subtitle:String?, coordinate: CLLocationCoordinate2D)
    {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        
        super.init()
    }
}
