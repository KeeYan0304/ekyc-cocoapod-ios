//
//  OCRFRResponse.swift
//  VeryfyClientSDK
//
//  Created by Kee Chun Yan on 27/09/2023.
//

import Foundation

final class OCRFRResponse {

    struct ResModel: Decodable {
        let status: Bool?
        let http_code: Int?
        let message: String?
        let data: OCRFRInfo?
    }

    struct OCRFRInfo: Decodable {
        let documentType: String?
        let result: [DataItem]?
        let imageBestLiveness: FRItems?
        let score: Float?
    }

    struct DataItem: Decodable {
        let label: Label?
        let value: String?
    }

    struct Label: Decodable {
        let value: Int?
        let key: String?
        let description: String?
    }
    
    struct FRItems: Decodable {
        let probability: Float?
        let score: Float?
        let quality: Float?
    }
}

