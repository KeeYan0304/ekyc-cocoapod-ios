//
//  EKYCLoaderView.swift
//  VeryfyIntegrateSDK
//
//  Created by Kee Chun Yan on 27/09/2023.
//

import UIKit

class EKYCLoaderView: UIView {

    @IBOutlet var contentView: UIView!

    let kCONTENT_XIB_NAME = "EKYCLoaderView"
    @IBOutlet weak var gifImg: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
        loadGif()
    }
    
    func loadGif() {
        if let gifURL = Bundle.main.url(forResource: "Veryfy logo gif", withExtension: "gif") {
            if let gifData = try? Data(contentsOf: gifURL) {
                // Create a UIImage from the GIF data
                if let gifImage = UIImage.gif(data: gifData, frameDuration: 0.05) {                    // Assign the GIF image to the UIImageView
                    gifImg.image = gifImage
                }
            }
        }
    }
    
    
    

}
