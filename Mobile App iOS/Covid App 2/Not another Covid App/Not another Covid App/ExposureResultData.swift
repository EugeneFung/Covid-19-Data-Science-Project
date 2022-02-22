//
//  ExposureResultData.swift
//  Not another Covid App
//
//  Created by Eugene Fung on 18/9/21.
//

import Foundation

class ExposureResultData: NSObject, Decodable {
    

//    var result: ExposureRecordData?
//
//    private enum CodingKeys: String, CodingKey {
//        case result = "result"
//    }
    
    var exposureSite: [ExposureSiteData]?
    
    private enum CodingKeys: String, CodingKey {
        case exposureSite = "Sheet1"
    }
    
}
