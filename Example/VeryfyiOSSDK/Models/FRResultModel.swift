//
//  FRResultModel.swift
//  VeryFy
//
//  Created by Kee Chun Yan on 07/04/2023.
//

import Foundation
class FRResultModel: Codable {
    var probability: Double?
    var score: Double?
    var quality: Double?
    
    init() {}
    
    init(probability: Double, score: Double, quality: Double) {
        self.probability = probability
        self.score = score
        self.quality = quality
    }
}
