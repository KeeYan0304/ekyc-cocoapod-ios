//
//  FRParams.swift
//  VeryfyClientSDK
//
//  Created by Kee Chun Yan on 26/09/2023.
//

import Foundation

public final class FRParams: Encodable {
    
    public var referenceId: String
    public var selfieImage: Data
    
    public init() {
        self.referenceId = ""
        self.selfieImage = Data()
    }
    
    init(referenceId: String, selfieImage: Data) {
        self.referenceId = referenceId
        self.selfieImage = selfieImage
    }
}
