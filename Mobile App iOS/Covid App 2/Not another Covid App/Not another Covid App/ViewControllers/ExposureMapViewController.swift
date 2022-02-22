//
//  ExposureMapViewController.swift
//  Not another Covid App
//
//  Created by Eugene Fung on 19/9/21.
//

import UIKit
import CoreLocation
import MapKit

class ExposureMapViewController: UIViewController, CLLocationManagerDelegate {
    
    let REQUEST_STRING = "https://script.googleusercontent.com/macros/echo?user_content_key=PhTmYv5my8m2R7pMktxIwmHTVRrUyO6fts1HLhUbO4HhUgKqI8eJQmxUm9Fw1dtZvrFXOxQ5uzsKVFmbQJCXpXK_N3bMQumMOJmA1Yb3SEsKFZqtv3DaNYcMrmhZHmUMWojr9NvTBuBLhyHCd5hHa1GhPSVukpSQTydEwAEXFXgt_wltjJcH3XHUaaPC1fv5o9XyvOto09QuWI89K6KjOu0SP2F-BdwUGJi-JZxRIG_g6jhV0fgOJRjfYkfaVy7AmOdnk0ghk2dk1iMi49vjBT5dtDQyTqxM5y7FLqOV0Tk27B8Rh4QJTQ&lib=MnrE7b2I2PjfH799VodkCPiQjIVyBAxva"
    var exposureSitesList = [ExposureSiteData]()    //exposure site array
    var listCount = 0
    var geocoder = CLGeocoder()
    var mapPin = [String : Any]()
    var mapPinList = [[String : Any]]()
    
    var locationManager: CLLocationManager!
    
    var lattitude: Double = 0.0
    var longitude: Double = 0.0
    
    @IBOutlet weak var mapView: MKMapView!
    @IBAction func currentLocBtn(_ sender: Any) {
        let userZoomLatLong = CLLocation(latitude: lattitude, longitude: longitude)
        zoomLevel(location: userZoomLatLong)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //init location manager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        //check if location/gps enabled
        if CLLocationManager.locationServicesEnabled() {
            //location enabled
            print("Location Enabled")
            locationManager.startUpdatingLocation()
            //print(self.currentAddress)
        }
        else {
            //location not enabled
            print("Location Not Enabled")
        }
        
        // Do any additional setup after loading the view.
        
        //using current lat and long (uncomment this line to let user use current location)
        //let zoomLatLong = CLLocation(latitude: lattitude, longitude: longitude)
        
        //setting up zoom level (manually enter current location if using simulator on xCode, comment out if using code above)
        let zoomLatLong = CLLocation(latitude: -37.8136, longitude: 144.9631) //lat & long of center of melbourne
        
        zoomLevel(location: zoomLatLong)    //sets the zoom level of map ie. zoom to victoria
        
        requestSite() //request for expoure sites from api and loads locations as annotations on map
        

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //get current location
        let userLocation = locations[0] as CLLocation
        
        //get latitude and longitude
        self.lattitude = userLocation.coordinate.latitude
        self.longitude = userLocation.coordinate.longitude
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func requestSite() {
        guard let requestURL = URL(string: REQUEST_STRING) else {
            print("Invalid URL.")
            return
        }
        
        let task = URLSession.shared.dataTask(with: requestURL) {
            (data, response, error) in

            if let error = error {
                print(error)
                return
            }
            do {
                let decoder = JSONDecoder()
                let exposureResultData = try decoder.decode(ExposureResultData.self, from: data!)
                if let exposureSites = exposureResultData.exposureSite {
                    self.exposureSitesList.append(contentsOf: exposureSites)
                    
                    //access exposureSiteList here

                    for i in self.exposureSitesList{
                        self.listCount = self.listCount + 1
                        if(i.longitude != nil){
                            

                            var tempMapPin = self.mapPin
                            tempMapPin["title"] = i.siteTitle
                            tempMapPin["latitude"] = i.latitude
                            tempMapPin["longitude"] = i.longitude
                            
                            self.mapPinList.append(tempMapPin)
                            
                        }else{
//                            self.exposureSitesList.remove(at: self.listCount) //remove data with no site address
                        }
                    }

                    self.createAnnotations(locations: self.mapPinList)
                }
            } catch let err {
                print(err)
            }
        }
        task.resume()
    }
    
    func createAnnotations(locations: [[String : Any]]){
        for location in locations{
            let annotations = MKPointAnnotation()
            annotations.title = location["title"] as? String
            annotations.coordinate = CLLocationCoordinate2D(latitude: location["latitude"] as! CLLocationDegrees, longitude: location["longitude"] as! CLLocationDegrees)
            mapView.addAnnotation(annotations)
        }
    }
    
    
    let distanceSpan: CLLocationDistance = 10000 //in meters
    
    func zoomLevel(location: CLLocation){
        //create new region for zooom level
        let mapCoordinates = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: distanceSpan, longitudinalMeters: distanceSpan)
        //set new region
        mapView.setRegion(mapCoordinates, animated: true)
        
    }

}
