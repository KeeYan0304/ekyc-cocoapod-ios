//
//  FRResultView.swift
//  VeryFy
//
//  Created by Kee Chun Yan on 05/04/2023.
//

import UIKit

protocol FRResultViewDelegate: AnyObject {
    func retrySelfie()
    func retryOCRFR()
}

class FRResultView: UIView {

    let kCONTENT_XIB_NAME = "FRResultView"
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var btnNext: UIView!
    @IBOutlet weak var imgPreview: UIImageView!
    
    @IBOutlet weak var btnRetry: UIView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var lblRetry: UILabel!
    @IBOutlet weak var lblRetryMsg: UILabel!
    @IBOutlet weak var selfieErrView: UIStackView!
    
    weak var parentVC: EKYCViewController?
    
    weak var delegate: FRResultViewDelegate?
    
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
        let sdkBundle = Bundle(for: FRResultView.self)
        sdkBundle.loadNibNamed("FRResultView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imgPreview.backgroundColor = K.Colors.imageBgColor
        imgPreview.contentMode = .scaleToFill
        btnRetry.backgroundColor = K.Colors.primaryColor
        btnRetry.isUserInteractionEnabled = true
        btnNext.isUserInteractionEnabled = true
        btnRetry.layer.cornerRadius = btnRetry.frame.height / 2
        btnNext.layer.cornerRadius = btnNext.frame.height / 2
        btnRetry.clipsToBounds = true
        btnNext.clipsToBounds = true
//        let tapRetry = UITapGestureRecognizer(target: self, action: #selector(navToSelfie))
//        btnRetry.addGestureRecognizer(tapRetry)
        let tapRetryOCR = UITapGestureRecognizer(target: self, action: #selector(retryOCRFR))
        btnRetry.addGestureRecognizer(tapRetryOCR)
        retrySelfieGesture = tapRetryOCR
        selfieErrView.isHidden = true
        label1.backgroundColor = .lightGray
    }
    
    @objc func navToSelfie() {
        delegate?.retrySelfie()
        btnRetry.isUserInteractionEnabled = false
        btnRetry.backgroundColor = K.Colors.disableColor
    }
    
    func initData(_ model: FRModel?, image: Data, count: Int) {
        imgPreview.image = UIImage(data: image)
        imgPreview.contentMode = .scaleAspectFit
//        let tapRetryOCR = UITapGestureRecognizer(target: self, action: #selector(retryOCRFR))
//        btnRetry.addGestureRecognizer(tapRetryOCR)
        if model?.score ?? 0.0 < 80 {
            if count > 0 {
                label2.text = "Verification Failed!"
                label3.text = "Document Not Readable"
                label1.isHidden = true
                selfieErrView.isHidden = false
                lblRetryMsg.isHidden = true
                btnNext.isUserInteractionEnabled = false
                btnNext.backgroundColor = K.Colors.disableColor
                btnRetry.isUserInteractionEnabled = true
            } else {
                label2.text = "Verification Failed!"
                label3.text = "Selfie did not match!"
                label1.isHidden = true
                selfieErrView.isHidden = false
                lblRetry.text = "Try Again"
//                if let gestureRecognizer = retrySelfieGesture {
//                    btnRetry.removeGestureRecognizer(gestureRecognizer)
//                }
                btnNext.isHidden = true
                lblRetryMsg.text = "You may try again by clicking on this button."
                lblRetryMsg.isHidden = false
                btnRetry.isUserInteractionEnabled = true
                btnRetry.backgroundColor = K.Colors.primaryColor
            }
        }
        else {
            if count > 0 {
                btnRetry.isUserInteractionEnabled = true
                btnRetry.backgroundColor = K.Colors.primaryColor
            } else {
                btnRetry.isUserInteractionEnabled = false
                btnRetry.backgroundColor = K.Colors.disableColor
            }
            label1.isHidden = false
            label1.text = " FR SCORE: \(model?.score?.description ?? "")"
            lblRetryMsg.isHidden = true
            selfieErrView.isHidden = true
            btnNext.isUserInteractionEnabled = true
            btnNext.backgroundColor = K.Colors.primaryColor
            let tapEnd = UITapGestureRecognizer(target: self, action: #selector(endSession))
            btnNext.addGestureRecognizer(tapEnd)
        }
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
        parentVC?.delegate?.eKYCViewControllerDidSessionEnded(parentVC ?? EKYCViewController())
        parentVC?.navigationController?.popToRootViewController(animated: false)
    }
}
