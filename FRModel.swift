//
//  FRModel.swift
//  first-api-demo-app
//
//  Created by Kee Chun Yan on 11/09/2023.
//

import Foundation
public class FRModel: NSObject {
    public var probability: Float?
    public var score: Float?
    public var quality: Float?
    
    init(probability: Float, score: Float, quality: Float) {
        self.probability = probability
        self.score = score
        self.quality = quality
    }
}
