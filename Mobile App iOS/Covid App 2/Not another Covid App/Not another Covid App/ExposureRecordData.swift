//
//  ExposureRecordData.swift
//  Not another Covid App
//
//  Created by Eugene Fung on 18/9/21.
//

import Foundation
//not used 
class ExposureRecordData: NSObject, Decodable {
    
    var exposureSite: [ExposureSiteData]?
    
    private enum CodingKeys: String, CodingKey {
        case exposureSite = "records"
    }
    
}
