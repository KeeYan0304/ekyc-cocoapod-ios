//
//  Config.swift
//
//  Created by Chen Qizhi on 2019/10/15.
//

import UIKit

enum QCropper {
    enum Config {
        static var croppingImageShortSideMaxSize: CGFloat = 1280
        static var croppingImageLongSideMaxSize: CGFloat = 5120 // 1280 * 4
        
        static var highlightColor = UIColor(red: 249 / 255.0, green: 214 / 255.0, blue: 74 / 255.0, alpha: 1)
        
        static var resourceBundle = Bundle(for: CropperViewController.self)
    }
}
