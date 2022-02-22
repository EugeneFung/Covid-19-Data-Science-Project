//
//  FirebaseController.swift
//  Not another Covid App
//
//  Created by adam luqman on 18/08/2021.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class FirebaseController: NSObject, DatabaseProtocol {
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var locationList: [Locations]
    
    var authController: Auth
    var database: Firestore
    var locationsRef: CollectionReference?
    
    override init() {
        //configure firebase
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        locationList = [Locations]()
        
        super.init()
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        listener.onLocationChange(change: .update, locations: locationList)
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    
    
    func cleanup() {
    }
    
    func addLocations(id: String, locationName: String, postcode: String, date: String, time: String, lattitude: Double, longitude: Double) -> Locations {
        
        let newlocation = Locations()
        newlocation.id = id
        newlocation.location = locationName
        newlocation.postcode = postcode
        newlocation.date = date
        newlocation.time = time
        newlocation.lattitude = lattitude
        newlocation.longitude = longitude
        
        return newlocation
    }
    
    func deleteLocations(location: Locations) {
        
        if let locationID = location.id {
            locationsRef?.document(locationID).delete()
        }
    }
    
    
    
    
}
