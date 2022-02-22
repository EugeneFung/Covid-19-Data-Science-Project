//
//  TestingSiteData.swift
//  Not another Covid App
//
//  Created by Eugene Fung on 24/8/21.
//

import Foundation

class TestingSiteData: NSObject, Decodable {
    
    var siteName: String
    var facility: String
    var website: String?
    var phone: String?
    var siteFacilities: String?
    var openingHours: String?
    var address: String
    var suburb: String
    var state: String
    var postcode: String
    var LGA: String
    var delaytext: String?
    var requirements: String?
    var symptomaticTesting: String
    var directions: String
    var testTracker: String
    var ageLimit: String?
    var addressOther: String?
    var serviceFormat: String
    
//    private enum RootKeys: String, CodingKey {
//        case records
//    }
    
    
//    private enum SiteKeys: String, CodingKey {
//        case sitename = "Site_Name"
//        case facility = "Facility"
//        case website = "Website"
//        case phone = "Phone"
//        case siteFacilities = "Site_Facilities"
//        case openingHours = "Service_Availability"
//        case address = "Address"
//        case suburb = "Suburb"
//        case state = "State"
//        case postcode = "Postcode"
//        case LGA
//        case delaytext
//        case requirements = "Requirements"
//        case symptomaticTesting = "Symptomatic testing only"
//        case directions = "Directions"
//        case testTracker = "TestTracker"
//        case ageLimit = "AgeLimit"
//        case addressOther = "AddressOther"
//        case serviceFormat = "ServiceFormat"
//    }
    
    private enum SiteKeys: String, CodingKey {
        case Site_Name
        case Facility
        case Website
        case Phone
        case Site_Facilities
        case Service_Availability
        case Address
        case Suburb
        case State
        case Postcode
        case LGA
        case delaytext
        case Requirements
        case symptomaticTesting = "Symptomatic testing only"
        case Directions
        case TestTracker
        case AgeLimit
        case AddressOther
        case ServiceFormat
    }
    
    required init(from decoder: Decoder) throws {
        // Get the root container first
//        let rootContainer = try decoder.container(keyedBy: RootKeys.self)
//
//        let siteContainer = try rootContainer.nestedContainer(keyedBy:
//                                                                SiteKeys.self, forKey: .records)
        
        let siteContainer = try decoder.container(keyedBy: SiteKeys.self)
        
//      get site info
        siteName = try siteContainer.decode(String.self, forKey: .Site_Name)
//        var facility: String
        facility = try siteContainer.decode(String.self, forKey: .Facility)
//        var website: String?
        website = try? siteContainer.decode(String.self, forKey: .Website)
//        var phone: String?
        phone = try? siteContainer.decode(String.self, forKey: .Phone)
//        var siteFacilities: String?
        siteFacilities = try? siteContainer.decode(String.self, forKey: .Site_Facilities)
//        var openingHours: String?
        openingHours = try? siteContainer.decode(String.self, forKey: .Service_Availability)
//        var address: String
        address = try siteContainer.decode(String.self, forKey: .Address)
//        var suburb: String
        suburb = try siteContainer.decode(String.self, forKey: .Suburb)
//        var state: String
        state = try siteContainer.decode(String.self, forKey: .State)
//        var postcode: String
        postcode = try siteContainer.decode(String.self, forKey: .Postcode)
//        var LGA: String
        LGA = try siteContainer.decode(String.self, forKey: .LGA)
//        var delaytext: String?
        delaytext = try? siteContainer.decode(String.self, forKey: .delaytext)
//        var requirements: String?
        requirements = try? siteContainer.decode(String.self, forKey: .Requirements)
//        var symptomaticTesting: String
        symptomaticTesting = try siteContainer.decode(String.self, forKey: .symptomaticTesting)
//        var directions: String
        directions = try siteContainer.decode(String.self, forKey: .Directions)
//        var testTracker: String
        testTracker = try siteContainer.decode(String.self, forKey: .TestTracker)
//        var ageLimit: String?
        ageLimit = try? siteContainer.decode(String.self, forKey: .AgeLimit)
//        var addressOther: String?
        addressOther = try? siteContainer.decode(String.self, forKey: .AddressOther)
//        var serviceFormat: String
        serviceFormat = try siteContainer.decode(String.self, forKey: .ServiceFormat)
        
    }
    
    
}
