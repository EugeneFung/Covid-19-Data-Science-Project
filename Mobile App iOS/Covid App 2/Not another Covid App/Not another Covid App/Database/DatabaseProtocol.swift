//
//  DatabaseProtocol.swift
//  Not another Covid App
//
//  Created by adam luqman on 18/08/2021.
//

import Foundation

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case Locations
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onLocationChange(change: DatabaseChange, locations: [Locations])
}

protocol DatabaseProtocol: AnyObject {
    func cleanup()
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    func addLocations(id: String, locationName: String, postcode: String, date: String, time: String, lattitude: Double, longitude: Double) -> Locations
    
    func deleteLocations(location: Locations)
    
}
