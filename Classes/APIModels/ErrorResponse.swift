//
//  ErrorResponse.swift
//  VeryfyClientSDK
//
//  Created by Kee Chun Yan on 18/09/2023.
//

import Foundation
final class ErrorResponse {
    
    // Define the ResponseModel struct for the first JSON structure
    struct ErrModel: Decodable {
        let status: String?
        let http_code: String?
        let message: String?
    }
    
}

