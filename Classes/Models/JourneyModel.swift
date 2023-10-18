//
//  JourneyModel.swift
//  first-api-demo-app
//
//  Created by Kee Chun Yan on 13/09/2023.
//

import Foundation
public class JourneyModel: NSObject {
    public var sessionId: String?
    public var referenceId: String?
    public var maxRetry: Int?
    
//    override init() {}
    
    public init(sessionId: String, referenceId: String, maxRetry: Int) {
        self.sessionId = sessionId
        self.referenceId = referenceId
        self.maxRetry = maxRetry
    }
}
