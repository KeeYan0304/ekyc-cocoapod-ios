//
//  SelfieResultView.swift
//  VeryFy
//
//  Created by Kee Chun Yan on 05/04/2023.
//

import UIKit
import VeryfyiOSSDK

protocol SelfieResultViewDelegate: AnyObject {
    func retrySelfie()
    func retryOCRFR()
}

class SelfieResultView: UIView {

    let kCONTENT_XIB_NAME = "SelfieResultView"
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var btnNext: UIView!
    @IBOutlet weak var imgPreview: UIImageView!
    
    @IBOutlet weak var btnRetry: UIView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var lblRetry: UILabel!
    
    weak var parentVC: OCRViewController?
    
    weak var delegate: SelfieResultViewDelegate?
    
    var retryCount = 0
    
    var retrySelfieGesture: UITapGestureRecognizer?

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
        imgPreview.backgroundColor = K.Colors.imageBgColor
        imgPreview.contentMode = .scaleToFill
        btnRetry.backgroundColor = K.Colors.primaryColor
        btnRetry.isUserInteractionEnabled = true
        btnNext.isUserInteractionEnabled = true
        btnRetry.layer.cornerRadius = btnRetry.frame.height / 2
        btnNext.layer.cornerRadius = btnNext.frame.height / 2
        btnRetry.clipsToBounds = true
        btnNext.clipsToBounds = true
        let tapRetry = UITapGestureRecognizer(target: self, action: #selector(navToSelfie))
        btnRetry.addGestureRecognizer(tapRetry)
        retrySelfieGesture = tapRetry
        let tapDone = UITapGestureRecognizer(target: self, action: #selector(endSession))
        btnNext.addGestureRecognizer(tapDone)
        btnNext.isUserInteractionEnabled = true
        label1.backgroundColor = .lightGray
        label2.backgroundColor = .lightGray
        label3.backgroundColor = .lightGray
    }
    
    @objc func navToSelfie() {
        delegate?.retrySelfie()
    }
    
    func initData(_ model: FRModel?, image: Data) {
        imgPreview.image = UIImage(data: image)
        imgPreview.contentMode = .scaleAspectFit
        label1.isHidden = false
        label2.isHidden = false
        label3.isHidden = false
        label1.text = "Probability: \(model?.probability ?? 0.0)"
        label2.text = "Score: \(model?.score ?? 0.0)"
        label3.text = "Quality: \(model?.quality ?? 0.0)"
    }
    
    func convToPercentage(_ number: Double) -> String {
        let percentage = number * 100
        let formattedPercentage = String(format: "%.2f%%", percentage)
        return formattedPercentage
    }
    
    @objc func retryOCRFR() {
        removeFromSuperview()
        delegate?.retryOCRFR()
    }
    
    @objc func endSession() {
        parentVC?.navigationController?.popToRootViewController(animated: false)
    }
}
