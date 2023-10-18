//
//  OCRFRModel.swift
//  VeryfyClientSDK
//
//  Created by Kee Chun Yan on 27/09/2023.
//

import Foundation

public class OCRFRModel: Codable {
    
    public var documentType: String?

    public var descriptionValuePairs: [String: String]?
    
    public var probability: Int?
    public var score: Float?
    public var quality: Float?
    
    public init() {}
    
    init(documentType: String, descriptionValuePairs: [String: String], probability: Int, score: Float, quality: Float) {
        self.documentType = documentType
        self.descriptionValuePairs = descriptionValuePairs
        self.probability = probability
        self.score = score
        self.quality = quality
    }
}
