//
//  OCRModel.swift
//  first-api-demo-app
//
//  Created by Kee Chun Yan on 11/09/2023.
//

import Foundation

public class OCRModel: NSObject, Codable {
    
    public var documentType: String?

    public var ocrKeyValue: [String: String]?
    
    override public init() {}
    
    init(documentType: String, ocrKeyValue: [String: String]) {
        self.documentType = documentType
        self.ocrKeyValue = ocrKeyValue
    }
}
