//
//  Locations.swift
//  Not another Covid App
//
//  Created by adam luqman on 18/08/2021.
//

import UIKit
import FirebaseFirestoreSwift

class Locations: NSObject, Codable {
    var id: String?
    var location: String?
    var postcode: String?
    var date: String?
    var time: String?
    var lattitude: Double?
    var longitude: Double?
}
