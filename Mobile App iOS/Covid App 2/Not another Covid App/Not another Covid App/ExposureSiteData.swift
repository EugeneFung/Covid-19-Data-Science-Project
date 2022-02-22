//
//  ExposureSiteData.swift
//  Not another Covid App
//
//  Created by Eugene Fung on 18/9/21.
//

import Foundation

class ExposureSiteData: NSObject, Decodable {
    
    var suburb: String
    var siteTitle: String
    var siteAddress: String?
    var siteState: String
    var sitePostcode: Int?
    var exposureDate: String
    var exposureTime: String
    var exposureNote: String
    var adviceTitle: String
    var adviceInstructions: String
    var exposureTimeStart: String
    var exposureTimeEnd: String
    var fullAddress: String?
    var latitude: Double?
    var longitude: Double?
    
    
    private enum ExposureSiteKeys: String, CodingKey {
        case Suburb
        case Site_title
        case Site_streetaddress
        case Site_state
        case Site_postcode
        case Exposure_date
        case Exposure_time
        case Notes
        case Advice_title
        case Advice_instruction
        case Exposure_time_start_24
        case Exposure_time_end_24
        case full_address
        case latitude
        case longitude
    }
    
    required init(from decoder: Decoder) throws {
        let exposureSiteContainer = try decoder.container(keyedBy: ExposureSiteKeys.self)
        
//        get exposure site info
//        var suburb: String
        suburb = try exposureSiteContainer.decode(String.self, forKey: .Suburb)
//        var siteTitle: String
        siteTitle = try exposureSiteContainer.decode(String.self, forKey: .Site_title)
//        var siteAddress: String?
        siteAddress = try? exposureSiteContainer.decode(String.self, forKey: .Site_streetaddress)
//        var siteState: String
        siteState = try exposureSiteContainer.decode(String.self, forKey: .Site_state)
//        var sitePostcode: String?
        sitePostcode = try? exposureSiteContainer.decode(Int.self, forKey: .Site_postcode)
//        var exposureDate: String
        exposureDate = try exposureSiteContainer.decode(String.self, forKey: .Exposure_date)
//        var exposureTime: String
        exposureTime = try exposureSiteContainer.decode(String.self, forKey: .Exposure_time)
//        var exposureNote: String
        exposureNote = try exposureSiteContainer.decode(String.self, forKey: .Notes)
//        var adviceTitle: String
        adviceTitle = try exposureSiteContainer.decode(String.self, forKey: .Advice_title)
//        var adviceInstructions: String
        adviceInstructions = try exposureSiteContainer.decode(String.self, forKey: .Advice_instruction)
//        var exposureTimeStart: String
        exposureTimeStart = try exposureSiteContainer.decode(String.self, forKey: .Exposure_time_start_24)
//        var exposureTimeEnd: String
        exposureTimeEnd = try exposureSiteContainer.decode(String.self, forKey: .Exposure_time_end_24)
//        var fullAddress: String?
        fullAddress = try? exposureSiteContainer.decode(String.self, forKey: .full_address)
//        var latitude: Double?
        latitude = try? exposureSiteContainer.decode(Double.self, forKey: .latitude)
//        var longitude: Double?
        longitude = try? exposureSiteContainer.decode(Double.self, forKey: .longitude)
        
    }
    
}
