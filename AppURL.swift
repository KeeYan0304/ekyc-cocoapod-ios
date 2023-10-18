//
//  AppURL.swift
//  first-api-demo-app
//
//  Created by Kee Chun Yan on 05/09/2023.
//

import Foundation

private let apiURL = "https://ekycapi.veryfyglobal.com/api/centralize/"
struct AppURL {
    struct Step {
        static let Start = "\(apiURL)start"
        static let PerformOcr = "\(apiURL)okay-id"
        static let PerformFR = "\(apiURL)okay-face"
        static let PerformOCRFR = "\(apiURL)okay-id-face"
    }
}

func UrlRequested(url: URL, Method: String ) -> URLRequest {
    var request = URLRequest(url: url)
    request.addValue("en", forHTTPHeaderField: "Accept-Language")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue(ApiSDKConfiguration.shared.licenseKey ?? "", forHTTPHeaderField: "x-api-key")
    request.httpMethod = Method
    
    return request
}
