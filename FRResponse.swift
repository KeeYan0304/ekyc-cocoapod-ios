//
//  FRResponse.swift
//  first-api-demo-app
//
//  Created by Kee Chun Yan on 08/09/2023.
//

import Foundation

final class FRResponse {
    struct ResModel: Decodable {
        let status: Bool?
        let http_code: Int?
        let message: String?
        let data: FaceInfo?
    }
    
    struct FaceInfo: Decodable {
        let imageBestLiveness: Items?
//        let score: Float?
    }
    
    struct Items: Decodable {
        let probability: Float?
        let score: Float?
        let quality: Float?
    }
}
