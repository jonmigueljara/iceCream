//
//  ViewController.swift
//  iceCream
//
//  Created by Jon Miguel Jara on 9/22/17.
//  Copyright © 2017 Jon Miguel Jara. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


struct Venue {
    var name:String
    var distance: Int
    var lat: Double
    var long: Double
    var id: String
    
}


class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var zoomCount:Int = Int()
    var venueArray =  [Venue] ()
    
    var locationManager:CLLocationManager!
    let distanceSpan:Double = 500
    
    var currentLocation:CLLocation!
    var venueItems : [[String: AnyObject]]?
    
    var searchResults = [JSON]()

    @IBOutlet var mapView: MKMapView!
    
    let client_id = "CHQUJPJGWBB52W24RI4UTCPYY0CERJCI1VQZWAF3ZP1GOVMQ" // visit developer.foursqure.com for API key
    let client_secret = "CQIZZPJ3QLZTQCGOCZK4LOWAV1DG5DAYALF1YICW22KGD2TG" // visit developer.foursqure.com for API key
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        
    }
    
    /** searchForIceCream()
    * Calls Foursquare API and stores into a Venue Data structure
    */
    func searchForIceCream() {
        
//        var name:String = String()
//        var distance: Int = Int()
//        var lat: Double = Double()
//        var long: Double = Double()
//        var id: String = String()
        
        let url = "https://api.foursquare.com/v2/search/recommendations?ll=\(self.currentLocation.coordinate.latitude),\(self.currentLocation.coordinate.longitude)&v=20160607&categoryId=4bf58dd8d48988d1c9941735&limit=15&client_id=\(client_id)&client_secret=\(client_secret)"
        
        let request = NSMutableURLRequest(url: URL(string: url)!)

        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            if let data = data,
                let string = String(data: data, encoding: .utf8) {
                
                let json = JSON(data: data)
                self.searchResults = json["response"]["group"]["results"].arrayValue
                
                
                for (_, subJson) in json["response"]["group"]["results"] {
                    let name = subJson["venue"]["name"].stringValue
                    if !name.isEmpty {
                        print(subJson["venue"]["name"].string!)
                        self.venueArray.append(Venue(name:subJson["venue"]["name"].string!,
                                                 distance:subJson["venue"]["location"]["distance"].int!,
                                                 lat:subJson["venue"]["location"]["lat"].double!,
                                                 long:subJson["venue"]["location"]["lng"].double!,
                                                 id:subJson["venue"]["id"].string!))
//                        print(self.venueArray.count)
                    }
                }
                print(self.venueArray.count)
            }
        }
        
        
        
        task.resume()
    }
    
    

    let manager = CLLocationManager()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        let location = locations[0]
        self.currentLocation = locations[0]
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.05, 0.05)
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        mapView.setRegion(region, animated: true)
        self.mapView.showsUserLocation = true
        
        self.zoomCount+=1
        
        if zoomCount == 3 {
            searchForIceCream()
        }
        manager.stopUpdatingLocation()
        
    }
    
}
    





