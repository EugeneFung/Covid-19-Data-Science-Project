//
//  CheckInViewController.swift
//  Not another Covid App
//
//  Created by Eugene Fung on 12/8/21.
//

import UIKit
import CoreLocation

class CheckInViewController: UIViewController, CLLocationManagerDelegate {
    
    var currentAddress: String = "test"
    
    var locationManager: CLLocationManager!
    
    var lattitude: Double = 0.0
    var longitude: Double = 0.0
    var postcode: String = ""
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //get current location
        let userLocation = locations[0] as CLLocation
        
        //get latitude and longitude
        lattitude = userLocation.coordinate.latitude
        longitude = userLocation.coordinate.longitude
        
        print(lattitude)
        print(longitude)
        
        //get address
        let geocoder = CLGeocoder()
       
        let location = CLLocation(latitude: lattitude, longitude: longitude)
        geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            // street, suburb, state, post code, country
            var placeMark: CLPlacemark
//            if placemarks[0] != nil {
//                placeMark = placemarks![0]
//            }
            placeMark = placemarks![0]
            
            /*
            //street
            print(placeMark.subThoroughfare)
            print(placeMark.thoroughfare)
            //city
            print(placeMark.locality)
            //state/suburb
            print(placeMark.administrativeArea)
            //post code
            print(placeMark.postalCode)
            //country
            print(placeMark.country)
            */
            var line1 = " "
            if let street1 = placeMark.subThoroughfare {
                line1 += street1 + " "
            }
            if let street2 = placeMark.thoroughfare {
                line1 += street2
            }
            var line2 = " "
            if let city = placeMark.locality {
                line2 += city + ", "
            }
            if let suburb = placeMark.administrativeArea {
                line2 += suburb + " "
            }
            if let postCode = placeMark.postalCode {
                line2 += postCode
                self.postcode = postCode
            }
            var line3 = " "
            if let country = placeMark.country {
                line3 += country
            }
            self.currentAddress = line1 + "\n" + line2 + "\n" + line3
        })
        //print(self.currentAddress)
        //self.performSegue(withIdentifier: "checkInSegue", sender: nil)
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
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        //print(self.currentAddress)
        if segue.identifier == "checkInSegue" {
            let destination = segue.destination as! CurrentAddressViewController
            destination.currentAddress = self.currentAddress
            destination.lattitude = lattitude
            destination.longitude = longitude
            destination.postcode = postcode
            
        }
    }
}
