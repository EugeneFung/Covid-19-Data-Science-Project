//
//  SiteRecordData.swift
//  Not another Covid App
//
//  Created by Eugene Fung on 24/8/21.
//

import Foundation

class SiteRecordData: NSObject, Decodable {
    
    var testingSite: [TestingSiteData]?
    
    private enum CodingKeys: String, CodingKey {
        case testingSite = "records"
    }
    
}

