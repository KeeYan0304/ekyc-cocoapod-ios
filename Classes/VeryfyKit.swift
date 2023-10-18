//
//  VeryfyKit.swift
//  VeryfyiOSSDK
//
//  Created by Kee Chun Yan on 17/10/2023.
//

import Foundation

public class VeryfyKit {
    public weak var delegate: VeryfyDelegate?
    
    public static let shared = VeryfyKit()
    
    private init() {}
    
    public static func loadEKYCViewController(delegate: EKYCViewControllerDelegate? = nil) -> UIViewController? {
        let frameworkBundle = Bundle(for: VeryfyKit.self)
        let storyboard = UIStoryboard(name: "VeryfyFramework", bundle: frameworkBundle)
        let viewController = storyboard.instantiateViewController(withIdentifier: "EKYCViewController") as! EKYCViewController
        viewController.delegate = delegate
        return viewController
    }
    
    public func startJourney() {
        if let url = URL(string: "\(AppURL.Step.Start)") {
            let request = UrlRequested(url: url, Method: "POST")
            URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
                guard let self = self else { return }
                guard let dataResponse = data,
                      error == nil else {
                    self.delegate?.journeyCompleted(withResult: nil, errCode: "", errMsg: "Request Failed")
                    return
                }
                do {
                    let responseString = String(data: dataResponse, encoding: .utf8)
//                    print("journey response: \(responseString ?? "Nil")")
                    let responseDict = try JSONSerialization.jsonObject(with: dataResponse, options: []) as? [String: Any]
                    let statusCode = responseDict?["http_code"] as? Int
                    if statusCode != 200 {
                        let failedData = try JSONDecoder().decode(ErrorResponse.ErrModel.self, from: dataResponse)
                        self.delegate?.journeyCompleted(withResult: nil, errCode: failedData.http_code?.description ?? "", errMsg: failedData.message ?? "")
                        return
                    } else {
                        let successData = try JSONDecoder().decode(JourneyResponse.ResModel.self, from: dataResponse)
                        let model = JourneyModel(sessionId: successData.data?.sessionId?.description ?? "", referenceId: successData.data?.referenceId ?? "", maxRetry: successData.data?.maxRetry ?? 0)
                        self.delegate?.journeyCompleted(withResult: model, errCode: "", errMsg: "")
                    }
                } catch {
                    self.delegate?.journeyCompleted(withResult: nil, errCode: "", errMsg: "Decode failed") // Notify with nil result for failure
                }
            }.resume()
        } else {
            self.delegate?.journeyCompleted(withResult: nil, errCode: "", errMsg: "Request failed") // Notify with nil result for failure
        }
    }
    
    public func performOCR(ocrInput: OCRParams) {
        if let url = URL(string: "\(AppURL.Step.PerformOcr)") {
            var request = UrlRequested(url: url, Method: "POST")
            request.addValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            let httpBody = NSMutableData()
            httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
            httpBody.append("Content-Disposition: form-data; name=\"referenceId\"\r\n\r\n".data(using: .utf8)!)
            httpBody.append("\(ocrInput.referenceId)\r\n".data(using: .utf8)!)
            
            httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
            httpBody.append("Content-Disposition: form-data; name=\"imageType\"\r\n\r\n".data(using: .utf8)!)
            httpBody.append("\(ocrInput.imageType)\r\n".data(using: .utf8)!)
            
            httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
            httpBody.append("Content-Disposition: form-data; name=\"frontImage\"; filename=\"frontImage.jpg\"\r\n".data(using: .utf8)!)
            httpBody.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            httpBody.append(ocrInput.frontImage )
            httpBody.append("\r\n".data(using: .utf8)!)
            
            if !(ocrInput.backImage?.isEmpty ?? false) {
                httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
                httpBody.append("Content-Disposition: form-data; name=\"backImage\"; filename=\"backImage.jpg\"\r\n".data(using: .utf8)!)
                httpBody.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                httpBody.append(ocrInput.backImage ?? Data())
                httpBody.append("\r\n".data(using: .utf8)!)
            }
            
            if ((ocrInput.frontImageFlash?.isEmpty) == nil) {
                httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
                httpBody.append("Content-Disposition: form-data; name=\"frontImageFlash\"; filename=\"frontImageFlash.jpg\"\r\n".data(using: .utf8)!)
                httpBody.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                httpBody.append(ocrInput.frontImageFlash ?? Data())
                httpBody.append("\r\n".data(using: .utf8)!)
            }
            
            httpBody.append("--\(boundary)--".data(using: .utf8)!)
            
            if let requestBodyString = String(data: httpBody as Data, encoding: .utf8) {
//                print("Request Body:")
//                print(requestBodyString)
            }
            
            request.httpBody = httpBody as Data
            
            URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
                guard let self = self else { return }
                guard let dataResponse = data,
                      error == nil else {
                    self.delegate?.ocrCompleted!(withResult: nil, errCode: "", errMsg: "Request Failed")
                    return
                }
                if let httpResponse = response as? HTTPURLResponse {
                    let statusCode = httpResponse.statusCode
//                    print("HTTP Status Code: \(statusCode)")
                }
                do {
                    let responseString = String(data: dataResponse, encoding: .utf8)
                    print("OCR response: \(responseString ?? "Nil")")
                    let responseDict = try JSONSerialization.jsonObject(with: dataResponse, options: []) as? [String: Any]
                    let statusCode = responseDict?["http_code"] as? Int
                    if statusCode != 200 {
                        let failedData = try JSONDecoder().decode(ErrorResponse.ErrModel.self, from: dataResponse)
                        self.delegate?.ocrCompleted!(withResult: nil, errCode: failedData.http_code?.description ?? "", errMsg: failedData.message ?? "")
                        return
                    } else {
                        let successData = try JSONDecoder().decode(OCRResponse.ResModel.self, from: dataResponse)
                        let result = successData.data?.result
                        let documentType = successData.data?.documentType ?? ""
                        
                        // Create a dictionary to store description and value pairs
                        var descriptionValuePairs = [String: String]()
                        
                        for index in 0..<(result?.count ?? 0) {
                            let description = result?[index].label?.description ?? ""
                            let value = result?[index].value ?? ""
                            
                            // Add description and value to the dictionary
                            descriptionValuePairs[description] = value
                        }
                        let ocrModel = OCRModel(documentType: documentType, ocrKeyValue: descriptionValuePairs)
                        self.delegate?.ocrCompleted!(withResult: ocrModel, errCode: "", errMsg: "")
                    }
                } catch {
                    self.delegate?.ocrCompleted!(withResult: nil, errCode: "", errMsg: "Decode failed") // Notify with nil result for failure
                }
            }.resume()
        } else {
            self.delegate?.ocrCompleted!(withResult: nil, errCode: "", errMsg: "Request failed") // Notify with nil result for failure
        }
    }
    
    public func performFR(frInput: FRParams) {
        if let url = URL(string: "\(AppURL.Step.PerformFR)") {
            var request = UrlRequested(url: url, Method: "POST")
            request.addValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            let httpBody = NSMutableData()
            httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
            httpBody.append("Content-Disposition: form-data; name=\"referenceId\"\r\n\r\n".data(using: .utf8)!)
            httpBody.append("\(frInput.referenceId)\r\n".data(using: .utf8)!)
            
            httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
            httpBody.append("Content-Disposition: form-data; name=\"selfieImage\"; filename=\"selfieImage.jpg\"\r\n".data(using: .utf8)!)
            httpBody.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            httpBody.append(frInput.selfieImage)
            httpBody.append("\r\n".data(using: .utf8)!)
            
            httpBody.append("--\(boundary)--".data(using: .utf8)!)
            request.httpBody = httpBody as Data
            
            URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
                guard let self = self else { return }
                guard let dataResponse = data,
                      error == nil else {
                    self.delegate?.frCompleted!(withResult: nil, errCode: "", errMsg: "Request Failed")
                    return
                }
                if let httpResponse = response as? HTTPURLResponse {
                    let statusCode = httpResponse.statusCode
//                    print("HTTP Status Code: \(statusCode)")
                }
                do {
                    let responseString = String(data: dataResponse, encoding: .utf8)
//                    print("FR response: \(responseString ?? "Empty")")
                    let responseDict = try JSONSerialization.jsonObject(with: dataResponse, options: []) as? [String: Any]
                    let statusCode = responseDict?["http_code"] as? Int
                    if statusCode != 200 {
                        let failedData = try JSONDecoder().decode(ErrorResponse.ErrModel.self, from: dataResponse)
                        self.delegate?.frCompleted!(withResult: nil, errCode: failedData.http_code?.description ?? "", errMsg: failedData.message ?? "")
                        return
                    } else {
                        let successData = try JSONDecoder().decode(FRResponse.ResModel.self, from: dataResponse)
                        let result = successData.data
//                        let frModel = FRModel(probability: result?.imageBestLiveness?.probability ?? 0.0, score: result?.score ?? 0.0, quality: result?.imageBestLiveness?.quality ?? 0.0)
                        let frModel = FRModel(probability: result?.imageBestLiveness?.probability ?? 0.0, score: result?.imageBestLiveness?.score ?? 0.0, quality: result?.imageBestLiveness?.quality ?? 0.0)
                        self.delegate?.frCompleted!(withResult: frModel, errCode: "", errMsg: "")
                    }
                } catch {
                    self.delegate?.frCompleted!(withResult: nil, errCode: "", errMsg: "Decode failed") // Notify with nil result for failure
                }
            }.resume()
        } else {
            self.delegate?.frCompleted!(withResult: nil, errCode: "", errMsg: "Request failed") // Notify with nil result for failure
        }
    }
    
    public func performOCRFR(ocrFrInput: OCRFRParams) {
        if let url = URL(string: "\(AppURL.Step.PerformOCRFR)") {
            var request = UrlRequested(url: url, Method: "POST")
            request.addValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            let httpBody = NSMutableData()
            httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
            httpBody.append("Content-Disposition: form-data; name=\"referenceId\"\r\n\r\n".data(using: .utf8)!)
            httpBody.append("\(ocrFrInput.referenceId)\r\n".data(using: .utf8)!)
            
            httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
            httpBody.append("Content-Disposition: form-data; name=\"imageType\"\r\n\r\n".data(using: .utf8)!)
            httpBody.append("\(ocrFrInput.imageType)\r\n".data(using: .utf8)!)
            
            httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
            httpBody.append("Content-Disposition: form-data; name=\"frontImage\"; filename=\"frontImage.jpg\"\r\n".data(using: .utf8)!)
            httpBody.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            httpBody.append(ocrFrInput.frontImage )
            httpBody.append("\r\n".data(using: .utf8)!)
            
            if !(ocrFrInput.backImage?.isEmpty ?? false) {
                httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
                httpBody.append("Content-Disposition: form-data; name=\"backImage\"; filename=\"backImage.jpg\"\r\n".data(using: .utf8)!)
                httpBody.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                httpBody.append(ocrFrInput.backImage ?? Data())
                httpBody.append("\r\n".data(using: .utf8)!)
            }
            
            if ((ocrFrInput.frontImageFlash?.isEmpty) == nil) {
                httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
                httpBody.append("Content-Disposition: form-data; name=\"frontImageFlash\"; filename=\"frontImageFlash.jpg\"\r\n".data(using: .utf8)!)
                httpBody.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                httpBody.append(ocrFrInput.frontImageFlash ?? Data())
                httpBody.append("\r\n".data(using: .utf8)!)
            }
            
            httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
            httpBody.append("Content-Disposition: form-data; name=\"selfieImage\"; filename=\"selfieImage.jpg\"\r\n".data(using: .utf8)!)
            httpBody.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            httpBody.append(ocrFrInput.selfieImage )
            httpBody.append("\r\n".data(using: .utf8)!)
            
            httpBody.append("--\(boundary)--".data(using: .utf8)!)
            
            if let requestBodyString = String(data: httpBody as Data, encoding: .utf8) {
//                print("Request Body:")
                print(requestBodyString)
            }
            
            request.httpBody = httpBody as Data
            
            URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
                guard let self = self else { return }
                guard let dataResponse = data,
                      error == nil else {
                    self.delegate?.ocrFRCompleted!(withOCRResult: nil, frResult: nil, errCode: "", errMsg: "Request Failed")
                    return
                }
                if let httpResponse = response as? HTTPURLResponse {
                    let statusCode = httpResponse.statusCode
//                    print("HTTP Status Code: \(statusCode)")
                }
                do {
                    let responseString = String(data: dataResponse, encoding: .utf8)
//                    print("OCR & FR response: \(responseString ?? "Empty")")
                    let responseDict = try JSONSerialization.jsonObject(with: dataResponse, options: []) as? [String: Any]
                    let statusCode = responseDict?["http_code"] as? Int
                    if statusCode != 200 {
                        let failedData = try JSONDecoder().decode(ErrorResponse.ErrModel.self, from: dataResponse)
                        self.delegate?.ocrFRCompleted?(withOCRResult: nil, frResult: nil, errCode: failedData.http_code?.description ?? "", errMsg: failedData.message ?? "")
                        return
                    } else {
                        let successData = try JSONDecoder().decode(OCRFRResponse.ResModel.self, from: dataResponse)
                        let result = successData
                        let documentType = result.data?.documentType
                        
                        // Create a dictionary to store description and value pairs
                        var descriptionValuePairs = [String: String]()
                        
                        for index in 0..<(result.data?.result?.count ?? 0) {
                            let description = result.data?.result?[index].label?.description ?? ""
                            let value = result.data?.result?[index].value ?? ""
                            
                            // Add description and value to the dictionary
                            descriptionValuePairs[description] = value
                        }
//                        let ocrFRModel = OCRFRModel(documentType: documentType, descriptionValuePairs: descriptionValuePairs, probability: result.frData?.imageBestLiveness?.probability ?? 0, score: result.frData?.score ?? 0.0, quality: result.data?.imageBestLiveness?.quality ?? 0.0)
                        let ocrModel = OCRModel(documentType: documentType ?? "", ocrKeyValue: descriptionValuePairs)
                        let frModel = FRModel(probability: result.data?.imageBestLiveness?.probability ?? 0.0, score: result.data?.score ?? 0.0, quality: result.data?.imageBestLiveness?.quality ?? 0.0)
                        self.delegate?.ocrFRCompleted!(withOCRResult: ocrModel, frResult: frModel, errCode: "", errMsg: "")
                    }
                } catch {
                    self.delegate?.ocrFRCompleted!(withOCRResult: nil, frResult: nil, errCode: "", errMsg: "Decode failed")// Notify with nil result for failure
                }
            }.resume()
        } else {
            self.delegate?.ocrFRCompleted!(withOCRResult: nil, frResult: nil, errCode: "", errMsg: "Request failed")
        }
    }
}

@objc public protocol VeryfyDelegate: AnyObject {
    func journeyCompleted(withResult result: JourneyModel?, errCode: String, errMsg: String)
    @objc optional func ocrCompleted(withResult result: OCRModel?, errCode: String?, errMsg: String?)
    @objc optional func frCompleted(withResult result: FRModel?, errCode: String, errMsg: String)
    @objc optional func ocrFRCompleted(withOCRResult result: OCRModel?, frResult: FRModel?, errCode: String, errMsg: String)
}
