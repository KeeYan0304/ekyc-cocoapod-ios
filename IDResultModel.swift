//
//  IDResultModel.swift
//  VeryFy
//
//  Created by Kee Chun Yan on 05/04/2023.
//

import Foundation

class IDResultModel: Codable {
    var description: String?
    var value: String?
    
    init() {}
    
    init(description: String, value: String) {
        self.description = description
        self.value = value
    }
}
