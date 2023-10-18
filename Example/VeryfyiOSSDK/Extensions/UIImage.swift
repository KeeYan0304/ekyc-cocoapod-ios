//
//  UIImage.swift
//  VeryfyIntegrateSDK
//
//  Created by Kee Chun Yan on 27/09/2023.
//

import UIKit

extension UIImage {
    static func gif(data: Data, frameDuration: TimeInterval) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        
        var images: [UIImage] = []
        
        let count = CGImageSourceGetCount(source)
        
        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                let uiImage = UIImage(cgImage: cgImage)
                images.append(uiImage)
            }
        }
        
        if images.count == 1 {
            return images.first
        } else {
            return UIImage.animatedImage(with: images, duration: Double(count) * frameDuration)
        }
    }
}
