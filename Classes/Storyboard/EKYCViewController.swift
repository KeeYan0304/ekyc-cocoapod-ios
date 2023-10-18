//
//  EKYCViewController.swift
//  VeryfyClientSDK
//
//  Created by Kee Chun Yan on 02/10/2023.
//

import UIKit

enum StepStatus {
    case idPending
    case selfiePending
    case completed
}

public protocol EKYCViewControllerDelegate: AnyObject {
    func eKYCViewControllerDidSessionEnded(_ viewController: EKYCViewController)
    
}

public class EKYCViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var containerView: UIView!
    
    private var referenceId = ""
    
    var selfieImage = Data()
    
    var ocrFRParam = OCRFRParams()
    
    var currentStepStatus = StepStatus.idPending
    
    var ocrModel: OCRModel?
    
    var frModel: FRModel?
    
    var maxRetry = 1
    
    var sessionEnded = false
    
    weak var delegate: EKYCViewControllerDelegate?
    
    lazy var uploadView: EKYCCapView = {
        let capView = EKYCCapView()
        capView.translatesAutoresizingMaskIntoConstraints = false
        return capView
    }()
    
    lazy var cameraView: CameraView = {
        let view = CameraView()
        return view
    }()
    
    lazy var ocrResultView: OCRResultView = {
        let ocrResView = OCRResultView()
        ocrResView.translatesAutoresizingMaskIntoConstraints = false
        return ocrResView
    }()
    
    lazy var faceResultView: FRResultView = {
        let faceResultView = FRResultView()
        faceResultView.translatesAutoresizingMaskIntoConstraints = false
        return faceResultView
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        VeryfyKit.shared.delegate = self
        VeryfyKit.shared.startJourney()
        initOCRView()
        scrollView.bounces = false
    }
    
    private func initOCRView() {
        uploadView.parentVC = self
        uploadView.delegate = self
        containerView.addSubview(uploadView)
        containerView.layoutIfNeeded()
        scrollView.setContentOffset(CGPoint(x: 0, y: -scrollView.contentInset.top), animated: false)
        let trailingAnchor = uploadView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0)
        let leadingAnchor = uploadView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0)
        let topAnchor = uploadView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 0)
        let bottomAnchor = uploadView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0)
        NSLayoutConstraint.activate([trailingAnchor, leadingAnchor, topAnchor, bottomAnchor])
    }
    
    private func initFRView() {
        uploadView.backImg.image = nil
        uploadView.frontImg.image = nil
        uploadView.frontImgFlash.image = nil
        containerView.addSubview(uploadView)
        uploadView.docView.isHidden = true
        uploadView.backStackView.isHidden = true
        uploadView.flashStackView.isHidden = true
        uploadView.lblCaptureFront.text = "Capture Selfie"
        uploadView.picType = .selfie
        uploadView.initBtns()
        uploadView.topConstraint.constant = 20
        uploadView.initBtns()
        containerView.layoutIfNeeded()
        scrollView.setContentOffset(CGPoint(x: 0, y: -scrollView.contentInset.top), animated: false)
        let trailingAnchor = uploadView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0)
        let leadingAnchor = uploadView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0)
        let topAnchor = uploadView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 0)
        let bottomAnchor = uploadView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0)
        NSLayoutConstraint.activate([trailingAnchor, leadingAnchor, topAnchor, bottomAnchor])
    }
    
     func showCameraView() {
        cameraView = CameraView()
        cameraView.initializeCamera(type: uploadView.picType)
        cameraView.frame = UIScreen.main.bounds
        cameraView.parentVC = self
        self.view.addSubview(cameraView)
//        print("showcameraview")
    }
    
    func showIDView() {
        currentStepStatus = .idPending
        showCaptureView(type: .idPending)
    }
    
    func showSelfieView() {
        currentStepStatus = .selfiePending
        showCaptureView(type: .selfiePending)
    }
    
    func showFullResult() {
        self.showLoader()
        VeryfyKit.shared.performOCRFR(ocrFrInput: ocrFRParam)
    }
    
    func showCaptureView(type: StepStatus) {
//        print("showcaptureview:\(type)")
        if maxRetry == 0 {
           promptMaxLimit()
            return
        }
        ocrResultView.removeFromSuperview()
        faceResultView.removeFromSuperview()
        uploadView.backImg.image = nil
        uploadView.frontImg.image = nil
        uploadView.frontImgFlash.image = nil
        containerView.addSubview(uploadView)
        uploadView.delegate = self
        uploadView.parentVC = self
        if type == .selfiePending {
            uploadView.docView.isHidden = true
            uploadView.flashStackView.isHidden = true
            uploadView.backStackView.isHidden = true
            uploadView.lblCaptureFront.text = "Capture Selfie"
            uploadView.picType = .selfie
            uploadView.initBtns()
            uploadView.topConstraint.constant = 20
        } else {
            uploadView.lblCaptureFront.text = "Capture ID Front"
            uploadView.picType = .front
            uploadView.setupDocUI()
        }
        uploadView.initBtns()
        containerView.layoutIfNeeded()
        scrollView.setContentOffset(CGPoint(x: 0, y: -scrollView.contentInset.top), animated: false)
        let trailingAnchor = uploadView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0)
        let leadingAnchor = uploadView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0)
        let topAnchor = uploadView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 0)
        let bottomAnchor = uploadView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0)
        NSLayoutConstraint.activate([trailingAnchor, leadingAnchor, topAnchor, bottomAnchor])
    }
    
    func promptFullFlowAlert(_ type: StepStatus) {
        let alert = UIAlertController(title: "Confirmation", message: "Do you want to proceed?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action: UIAlertAction!) in
            self.uploadView.docTableView.isHidden = true
            if type == .selfiePending {
                self.showSelfieView()
            } else {
                self.showFullResult()
            }
        }))
        alert.addAction(UIAlertAction(title: "Retry", style: .cancel, handler: { (action: UIAlertAction!) in
            self.uploadView.frontImg.image = nil
            self.uploadView.backImg.image = nil
            self.uploadView.frontImgFlash.image = nil
            if type == .idPending {
                self.uploadView.backStackView.isHidden = true
                self.ocrResultView.removeFromSuperview()
                self.containerView.layoutIfNeeded()
                self.scrollView.setContentOffset(CGPoint(x: 0, y: -self.scrollView.contentInset.top), animated: false)
                self.uploadView.picType = .front
                self.uploadView.captureFront()
            } else {
                self.uploadView.picType = .selfie
                self.uploadView.captureSelfie()
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func showLoader() {
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = .medium
        loadingIndicator.startAnimating();

        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    
    func promptErrMsg(msg: String) {
        
        let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { _ in
            if self.maxRetry > 0 {
                self.showIDView()
            } else {
                self.promptMaxLimit()
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func promptMaxLimit() {
        let alert = UIAlertController(title: "Alert", message: "Maximum attempt reached", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { _ in
            self.delegate?.eKYCViewControllerDidSessionEnded(self)
        }))
        present(alert, animated: true, completion: nil)
    }
}
extension EKYCViewController: CaptureViewDelegate {
    func getOCRResult(frontImg: Data, backImg: Data, frontImgFlash: Data, isFlash: Bool) {
        if isFlash == false {
            ocrFRParam.imageType = 0
        } else {
            ocrFRParam.imageType = 1
        }
        ocrFRParam.backImage = backImg
        ocrFRParam.frontImage = frontImg
        ocrFRParam.frontImageFlash = frontImgFlash
        ocrFRParam.referenceId = referenceId
        promptFullFlowAlert(.selfiePending)
    }
    
    func getFRResult(selfieImg: Data) {
        let param = FRParams()
        param.referenceId = referenceId
        param.selfieImage = selfieImg
        self.selfieImage = selfieImg
        ocrFRParam.selfieImage = selfieImg
        promptFullFlowAlert(.completed)
    }
    
    func showOCRResult() {
        dismiss(animated: true) {
            self.uploadView.removeFromSuperview()
            self.containerView.addSubview(self.ocrResultView)
            self.ocrResultView.delegate = self
            self.ocrResultView.parentVC = self
            self.ocrResultView.initData(self.ocrModel ?? OCRModel())
            self.ocrResultView.setupBtns()
            let trailingAnchor = self.ocrResultView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: 0)
            let leadingAnchor = self.ocrResultView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 0)
            let topAnchor = self.ocrResultView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 0)
            let bottomAnchor = self.ocrResultView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: 0)
            NSLayoutConstraint.activate([trailingAnchor, leadingAnchor, topAnchor, bottomAnchor])
            self.containerView.layoutIfNeeded()
            self.scrollView.setContentOffset(CGPoint(x: 0, y: -self.scrollView.contentInset.top), animated: false)
        }
    }
    
    func showFRResultView(result: FRModel?) {
//        print("showfrresultview")
        self.uploadView.removeFromSuperview()
        self.ocrResultView.removeFromSuperview()
        self.containerView.layoutIfNeeded()
        self.containerView.addSubview(self.faceResultView)
        self.faceResultView.delegate = self
        self.faceResultView.parentVC = self
        self.faceResultView.initData(result, image: self.selfieImage, count: maxRetry)
        let trailingAnchor = self.faceResultView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: 0)
        let leadingAnchor = self.faceResultView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 0)
        let topAnchor = self.faceResultView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 0)
        let bottomAnchor = self.faceResultView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: 0)
        NSLayoutConstraint.activate([trailingAnchor, leadingAnchor, topAnchor, bottomAnchor])
    }
}

extension EKYCViewController: VeryfyDelegate {
    
    public func journeyCompleted(withResult result: JourneyModel?, errCode: String, errMsg: String) {
        self.referenceId = result?.referenceId ?? ""
        self.maxRetry = result?.maxRetry ?? 0
//        print("result:\(result?.referenceId ?? "") \(result?.sessionId ?? "") \(errCode) \(errMsg)")
    }
    
    public func ocrFRCompleted(withOCRResult result: OCRModel?, frResult: FRModel?, errCode: String, errMsg: String) {
//        print("ocrfrcompleted:\(errCode) \(errMsg)")
        self.maxRetry -= 1
        ocrModel = result
        frModel = frResult
        if errMsg == "" {
            DispatchQueue.main.async {
                self.showOCRResult()
            }
        } else {
            DispatchQueue.main.async {
                self.dismiss(animated: true) {
                    self.promptErrMsg(msg: errMsg)
                }
            }
        }
    }
}

extension EKYCViewController: OCRResultViewDelegate {
    func navRetry() {
        showIDView()
    }
    
    func doneOCR() {
        
    }
    
    func showFRResult() {
        self.showFRResultView(result: frModel)
    }
}
extension EKYCViewController: FRResultViewDelegate {
    func retrySelfie() {
        showSelfieView()
    }
    
    func retryOCRFR() {
        showIDView()
    }
}
