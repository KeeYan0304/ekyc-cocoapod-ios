//
//  OCRResponse.swift
//  first-api-demo-app
//
//  Created by Kee Chun Yan on 08/09/2023.
//

import Foundation

final class OCRResponse {

    struct ResModel: Decodable {
        let status: Bool?
        let http_code: Int?
        let message: String?
        let data: Result?
    }

    struct Result: Decodable {
        let documentType: String?
        let result: [DataItem]?
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
}
