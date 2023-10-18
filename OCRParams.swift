//
//  OCRParams.swift
//  VeryfyClientSDK
//
//  Created by Kee Chun Yan on 25/09/2023.
//

import Foundation

public final class OCRParams: Encodable {
    
    public var referenceId: String
    public var imageType: Int
    public var frontImage: Data
    public var frontImageFlash: Data?
    public var backImage: Data?
    
    public init() {
        self.referenceId = ""
        self.imageType = 0
        self.frontImage = Data()
        self.frontImageFlash = nil
        self.backImage = nil
    }
    
    init(referenceId: String, frontImage: Data, backImage: Data?, frontImageFlash: Data?, imageType: Int) {
        self.referenceId = referenceId
        self.frontImage = frontImage
        self.imageType = imageType
        
        // Initialize optional properties
        self.frontImageFlash = frontImageFlash
        self.backImage = backImage
    }
}
