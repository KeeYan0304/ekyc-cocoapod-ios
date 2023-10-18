//
//  Credential.swift
//  first-api-demo-app
//
//  Created by Kee Chun Yan on 28/08/2023.
//

public class ApiSDKConfiguration {
    public static let shared = ApiSDKConfiguration()
    
    public var licenseKey: String?
    
    public func setLicenseKey(_ key: String) {
        licenseKey = key
    }
    
    private init() {}
}
