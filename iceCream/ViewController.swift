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





class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    

    let distanceSpan:Double = 500
    
    var currentLocation:CLLocation!
    var venueItems : [[String: AnyObject]]?
    let client_id = "CHQUJPJGWBB52W24RI4UTCPYY0CERJCI1VQZWAF3ZP1GOVMQ" // visit developer.foursqure.com for API key
    let client_secret = "CQIZZPJ3QLZTQCGOCZK4LOWAV1DG5DAYALF1YICW22KGD2TG" // visit developer.foursqure.com for API key
    var searchResults = [JSON]()
    var venueArray =  [Venue] ()
    var nearestVenue = Venue()
    var myRoute : MKRoute!


    @IBOutlet var mapView: MKMapView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        print(self.nearestVenue.name)
        
        setMapView()
        
        searchForIceCream()
        
        let directions = UIBarButtonItem(title: "Directions", style: .plain, target: self, action: #selector(getDirections))
        navigationItem.rightBarButtonItem = directions

        
        mapView.delegate = self
    
    }
    
    /** searchForIceCream()
    * Calls Foursquare API and stores into a Venue Data structure
    */
    
    func searchForIceCream() {
        
        let url = "https://api.foursquare.com/v2/search/recommendations?ll=\(self.currentLocation.coordinate.latitude),\(self.currentLocation.coordinate.longitude)&v=20160607&categoryId=4bf58dd8d48988d1c9941735&limit=15&client_id=\(client_id)&client_secret=\(client_secret)&openNow=1"
        //        print(url)
        
        let request = NSMutableURLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            if let data = data,
                let string = String(data: data, encoding: .utf8) {
                
                let json = JSON(data: data)
                
                
                self.searchResults = json["response"]["group"]["results"].arrayValue
                
                var iceCreamFlag : Bool
                for (_, subJson) in json["response"]["group"]["results"] {
                    var newVenue : Venue = Venue()
                    // flag to check if the venues are a restaurant
                    iceCreamFlag = false
                    let name = subJson["venue"]["name"].stringValue
                    if !name.isEmpty {
                        // check if it is a restaurant
                        for (_,category) in subJson["venue"]["categories"] {
                            if ((category["name"].string?.range(of: "Ice Cream")) != nil) {
                                iceCreamFlag = true
                            }
                        }
                        
                        if (iceCreamFlag) {
                            if let name = subJson["venue"]["name"].string {
                                newVenue.name = name
                            }
                            
                            if let distance = subJson["venue"]["location"]["distance"].int {
                                newVenue.distance = distance
                            }
                            
                            if let distance = subJson["venue"]["location"]["distance"].int {
                                newVenue.distance = distance
                            }
                            
                            if let lat = subJson["venue"]["location"]["lat"].double {
                                newVenue.lat = lat
                            }
                            
                            if let long = subJson["venue"]["location"]["lng"].double {
                                newVenue.long = long
                            }
                            
                            if let id = subJson["venue"]["location"]["id"].string {
                                newVenue.id = id
                            }
                            
                            
                            self.venueArray.append(newVenue)
                        }
                    }
                }
                
                self.venueArray.sort(by: { $0.distance < $1.distance})
                
                
                self.nearestVenue = self.venueArray[0]
                
                DispatchQueue.main.async {
                    let icePoint = iceCreamAnnotation(title: self.nearestVenue.name, coordinate: CLLocationCoordinate2D(latitude: self.nearestVenue.lat, longitude: self.nearestVenue.long))
                    self.mapView.addAnnotation(icePoint)
                    self.mapView.selectAnnotation(icePoint, animated: true)
                    
                    self.calcDirections(annotation: icePoint)
            
                }
                
            }
            
        }
        task.resume()
    }
    
    func setMapView () {
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.05, 0.05)
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        mapView.setRegion(region, animated: true)
        self.mapView.showsUserLocation = true
    }

 



func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
    if let annotation = annotation as? iceCreamAnnotation {
        let identifier = "pin"
        var view: MKPinAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKPinAnnotationView { // 2
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            // 3
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as! UIView
        }
        return view
    }
    return nil
}
    
    func getDirections() {
        let loc = mapView.annotations.first as! iceCreamAnnotation
        print(loc.title)
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        loc.mapItem().openInMaps(launchOptions: launchOptions)
    }
    
    

    func calcDirections(annotation: iceCreamAnnotation!) {
        let request: MKDirectionsRequest = MKDirectionsRequest()
        
        let currentLocationItem = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude), addressDictionary: nil))
        
        request.source = currentLocationItem
        request.destination = annotation.mapItem()
        
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        
        
        directions.calculate(completionHandler: {
            
            response, error in
            
            if error == nil {
                
                self.myRoute = response!.routes[0] as MKRoute
                self.mapView.add(self.myRoute.polyline)
                
            }
        })
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) ->MKOverlayRenderer {
        
        let myLineRenderer = MKPolylineRenderer(polyline: myRoute.polyline)
        
        myLineRenderer.strokeColor = UIColor.cyan
        
        myLineRenderer.lineWidth = 2
        
        return myLineRenderer
    }

    func plotPolyline(route: MKRoute) {
        // 1
        mapView.add(route.polyline)
        // 2
        if mapView.overlays.count == 1 {
            mapView.setVisibleMapRect(route.polyline.boundingMapRect,
                                      edgePadding: UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0),
                                      animated: false)
        }
    // 3
        else {
            let polylineBoundingRect =  MKMapRectUnion(mapView.visibleMapRect,
                                                       route.polyline.boundingMapRect)
            mapView.setVisibleMapRect(polylineBoundingRect,
                              edgePadding: UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0),
                              animated: false)
        }
    }



 }
