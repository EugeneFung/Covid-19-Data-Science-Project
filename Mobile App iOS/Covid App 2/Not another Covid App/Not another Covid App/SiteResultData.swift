//
//  SiteResultData.swift
//  Not another Covid App
//
//  Created by Eugene Fung on 25/8/21.
//

import Foundation

class SiteResultData: NSObject, Decodable {
    
//    var testingSite: [TestingSiteData]?
    var result: SiteRecordData?
    
    private enum CodingKeys: String, CodingKey {
        case result = "result"
    }
    
}
