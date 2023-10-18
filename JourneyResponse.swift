//
//  JourneyResponse.swift
//  first-api-demo-app
//
//  Created by Kee Chun Yan on 28/08/2023.
//

import Foundation
final class JourneyResponse {
    
    // Define the ResponseModel struct for the first JSON structure
    struct ResModel: Decodable {
        let status: Bool?
        let http_code: Int?
        let message: String?
        let data: Data?
    }
    
    struct Data: Decodable {
        let sessionId: Int?
        let referenceId: String?
        let maxRetry: Int?
    }
}
