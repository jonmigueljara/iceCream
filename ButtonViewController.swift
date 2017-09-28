//
//  ButtonViewController.swift
//  
//
//  Created by Jon Miguel Jara on 9/27/17.
//
//

import UIKit
import CoreLocation


class ButtonViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var currentLocation:CLLocation!
    var flag = true
    let client_id = "CHQUJPJGWBB52W24RI4UTCPYY0CERJCI1VQZWAF3ZP1GOVMQ" // visit developer.foursqure.com for API key
    let client_secret = "CQIZZPJ3QLZTQCGOCZK4LOWAV1DG5DAYALF1YICW22KGD2TG" // visit developer.foursqure.com for API key
    var searchResults = [JSON]()
    var venueArray =  [Venue] ()
    var nearestVenue = Venue()
    
    @IBOutlet weak var iceCreamButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // set up location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        // add action to the coffee button
        iceCreamButton.addTarget(self, action: #selector(getCurrentLocation), for: .touchUpInside)
        
        print(nearestVenue.name)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // always make sure the coffeeButton is visible
        if iceCreamButton.isHidden {
            iceCreamButton.isHidden = false
        }
        // request location access
        locationManager.requestWhenInUseAuthorization()
        flag = true
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getCurrentLocation() {
        // check if access is granted
        locationManager.startUpdatingLocation()
    
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // show the activity indicator
        iceCreamButton.isHidden = true
        
        
        // set a flag so segue is only called once
        if flag {
            currentLocation = locations[0]
            locationManager.stopUpdatingLocation()
            flag = false
            performSegue(withIdentifier: "showIceCream", sender: self)
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass the latitude and longitude to the new view controller
        if segue.identifier == "showIceCream" {
            let vc = segue.destination as! ViewController
            vc.currentLocation = currentLocation
        }
    }
    
    
    
    
    
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
            }
            
        }
        task.resume()
    }
    
    func showLocationAlert() {
        let alert = UIAlertController(title: "Location Disabled", message: "Please enable location", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
