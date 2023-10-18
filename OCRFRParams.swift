//
//  OCRFRParams.swift
//  VeryfyClientSDK
//
//  Created by Kee Chun Yan on 27/09/2023.
//

import Foundation

public final class OCRFRParams: Encodable {
    
    public var referenceId: String
    public var imageType: Int
    public var frontImage: Data
    public var frontImageFlash: Data?
    public var backImage: Data?
    public var selfieImage: Data
    
    public init() {
        self.referenceId = ""
        self.imageType = 0
        self.frontImage = Data()
        self.frontImageFlash = nil
        self.backImage = nil
        self.selfieImage = Data()
    }
    
    init(referenceId: String, frontImage: Data, backImage: Data?, frontImageFlash: Data?, imageType: Int, selfieImage: Data) {
        self.referenceId = referenceId
        self.frontImage = frontImage
        self.imageType = imageType
        self.selfieImage = selfieImage
        // Initialize optional properties
        self.frontImageFlash = frontImageFlash
        self.backImage = backImage
    }
}
