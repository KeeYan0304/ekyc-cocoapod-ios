//
//  OCRViewController.swift
//  VeryfyIntegrateSDK
//
//  Created by Kee Chun Yan on 13/09/2023.
//

import UIKit
import VeryfyiOSSDK

enum StepStatus {
    case idPending
    case selfiePending
    case completed
}

enum EkycScenario {
    case ocr
    case fr
    case full
}

class OCRViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var lblSesId: UILabel!
    @IBOutlet weak var logoutView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var firstCircle: UIView!
    @IBOutlet weak var secCircle: UIView!
    @IBOutlet weak var thirdCircle: UIView!
    @IBOutlet weak var lblCapture: UILabel!
    @IBOutlet weak var firstDash: UIView!
    @IBOutlet weak var secDash: UIView!
    @IBOutlet weak var idTopStackView: UIStackView!
    @IBOutlet weak var selfieTopStackView: UIStackView!
    @IBOutlet weak var lblCompleteNum: UILabel!
    @IBOutlet weak var lblIDNum: UILabel!
    @IBOutlet weak var lblSelfieNum: UILabel!
    
    var selfieImage = Data()
    
    lazy var cameraView: CameraView = {
        let view = CameraView()
        return view
    }()
    
    lazy var resultIDView: IDResultView = {
        let view = IDResultView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var captureIDView: CaptureView = {
        let view = CaptureView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var resultFaceView: SelfieResultView = {
        let view = SelfieResultView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var ekycLoaderView: EKYCLoaderView = {
        let view = EKYCLoaderView()
        return view
    }()
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    let veryfyKit = VeryfyKit.shared
    
    var referenceId = ""
    
    var currentStepStatus = StepStatus.idPending
    
    var selfieRetryCount = 0
    
    var ocrModel: OCRModel?
    
    var frModel: FRModel?
    
    var flowType = EkycScenario.ocr
    
    var maxRetry = 1
    
    var sessionEnded = false
    
    var ocrFRParam = OCRFRParams()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getInfo()
        let tapLogout = UITapGestureRecognizer(target: self, action: #selector(backToSelectionPage))
        logoutView.addGestureRecognizer(tapLogout)
        logoutView.isUserInteractionEnabled = true
    }
    
    func getInfo() {
        veryfyKit.delegate = self
        veryfyKit.startJourney()
        initTopView()
        initContentView()
        ekycLoaderView.frame = UIScreen.main.bounds
        self.view.addSubview(ekycLoaderView)
        ekycLoaderView.isHidden = true
    }
    
    func initTopView() {
        topView.backgroundColor = K.Colors.primaryColor
        topView.clipsToBounds = true
        topView.layer.cornerRadius = 35
        topView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }

    func initContentView() {
        if flowType == .ocr || flowType == .full {
            showScanID()
        } else if flowType == .fr {
            showSelfieView()
        }
        firstCircle.layer.cornerRadius = firstCircle.frame.self.width / 2
        firstCircle.clipsToBounds = true
        secCircle.layer.cornerRadius = firstCircle.frame.self.width / 2
        secCircle.clipsToBounds = true
        thirdCircle.layer.cornerRadius = firstCircle.frame.self.width / 2
        thirdCircle.clipsToBounds = true
        lblCapture.setContentHuggingPriority(.defaultLow, for: .horizontal)
        setupTopBar()
    }
    
    func showScanID() {
        firstCircle.backgroundColor = .white
        secCircle.backgroundColor = K.Colors.pendingColor
        thirdCircle.backgroundColor = K.Colors.pendingColor
        showCaptureView(type: .idPending)
    }
    
    func setupTopBar() {
        if flowType == .ocr {
            selfieTopStackView.isHidden = true
            secDash.isHidden = true
            lblCompleteNum.text = "2"
        } else if flowType == .fr {
            idTopStackView.isHidden = true
            firstDash.isHidden = true
            lblCompleteNum.text = "2"
            lblSelfieNum.text = "1"
        }
    }
    
    func showCameraView() {
        cameraView = CameraView()
        cameraView.initializeCamera(type: captureIDView.picType)
        cameraView.frame = UIScreen.main.bounds
        cameraView.parentVC = self
        self.view.addSubview(cameraView)
    }
    
    func promptConfirmAlert(_ type: StepStatus, ocrInput: OCRParams?, frInput: FRParams?, isFlash: Bool) {
        let alert = UIAlertController(title: "Confirmation", message: "Do you want to proceed?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action: UIAlertAction!) in
            self.captureIDView.docTableView.isHidden = true
            self.promptLoad(ocrInput: ocrInput, frInput: frInput, isFlash: isFlash)
        }))
        alert.addAction(UIAlertAction(title: "Retry", style: .cancel, handler: { (action: UIAlertAction!) in
            self.captureIDView.frontImg.image = nil
            self.captureIDView.backImg.image = nil
            self.captureIDView.frontImgFlash.image = nil
            if type == .idPending {
                self.captureIDView.stackView3.isHidden = true
                self.resultIDView.removeFromSuperview()
                self.contentView.layoutIfNeeded()
                self.scrollView.setContentOffset(CGPoint(x: 0, y: -self.scrollView.contentInset.top), animated: false)
                self.captureIDView.picType = .front
                self.captureIDView.captureFront()
            } else {
                self.captureIDView.picType = .selfie
                self.captureIDView.captureSelfie()
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func promptFullFlowAlert(_ type: StepStatus) {
        let alert = UIAlertController(title: "Confirmation", message: "Do you want to proceed?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action: UIAlertAction!) in
            self.captureIDView.docTableView.isHidden = true
            if type == .selfiePending {
                self.showSelfieView()
            } else {
                self.showFullResult()
            }
        }))
        alert.addAction(UIAlertAction(title: "Retry", style: .cancel, handler: { (action: UIAlertAction!) in
            self.captureIDView.frontImg.image = nil
            self.captureIDView.backImg.image = nil
            self.captureIDView.frontImgFlash.image = nil
            if type == .idPending {
                self.captureIDView.stackView3.isHidden = true
                self.resultIDView.removeFromSuperview()
                self.contentView.layoutIfNeeded()
                self.scrollView.setContentOffset(CGPoint(x: 0, y: -self.scrollView.contentInset.top), animated: false)
                self.captureIDView.picType = .front
                self.captureIDView.captureFront()
            } else {
                self.captureIDView.picType = .selfie
                self.captureIDView.captureSelfie()
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func showLoader() {
        ekycLoaderView.isHidden = false
    }
    
    func hideLoader() {
        ekycLoaderView.isHidden = true
    }
    
    func promptLoad(ocrInput: OCRParams?, frInput: FRParams?, isFlash: Bool) {
        if self.currentStepStatus == .idPending {
            veryfyKit.performOCR(ocrInput: ocrInput ?? OCRParams())
        } else {
            veryfyKit.performFR(frInput: frInput ?? FRParams())
        }
        self.showLoader()
    }
    
    func showCaptureView(type: StepStatus) {
        if maxRetry == 0 {
           promptErrMsg(msg: "Maximum attempt reached")
            return
        }
        resultIDView.removeFromSuperview()
        resultFaceView.removeFromSuperview()
        captureIDView.backImg.image = nil
        captureIDView.frontImg.image = nil
        captureIDView.frontImgFlash.image = nil
        contentView.addSubview(captureIDView)
        captureIDView.delegate = self
        captureIDView.parentVC = self
        if type == .idPending {
            captureIDView.picType = .front
        } else {
            captureIDView.picType = .selfie
        }
        captureIDView.initBtns()
        contentView.layoutIfNeeded()
        scrollView.setContentOffset(CGPoint(x: 0, y: -scrollView.contentInset.top), animated: false)
        let trailingAnchor = captureIDView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0)
        let leadingAnchor = captureIDView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0)
        let topAnchor = captureIDView.topAnchor.constraint(equalTo: self.logoutView.bottomAnchor, constant: 0)
        let bottomAnchor = captureIDView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
        NSLayoutConstraint.activate([trailingAnchor, leadingAnchor, topAnchor, bottomAnchor])
    }
    
    func showOCRResult() {
        self.hideLoader()
        self.captureIDView.removeFromSuperview()
        self.contentView.addSubview(self.resultIDView)
        self.resultIDView.delegate = self
        self.resultIDView.parentVC = self
        self.resultIDView.initData(ocrModel ?? OCRModel())
        self.resultIDView.setupBtns()
        let trailingAnchor = self.resultIDView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0)
        let leadingAnchor = self.resultIDView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0)
        let topAnchor = self.resultIDView.topAnchor.constraint(equalTo: self.logoutView.bottomAnchor, constant: 0)
        let bottomAnchor = self.resultIDView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0)
        NSLayoutConstraint.activate([trailingAnchor, leadingAnchor, topAnchor, bottomAnchor])
        self.contentView.layoutIfNeeded()
        self.firstCircle.backgroundColor = K.Colors.completeColor
        self.secCircle.backgroundColor = K.Colors.pendingColor
        if flowType == .ocr {
            thirdCircle.backgroundColor = K.Colors.completeColor
        }
        self.scrollView.setContentOffset(CGPoint(x: 0, y: -self.scrollView.contentInset.top), animated: false)
    }
    
    func showFRResult(selfieImg: Data) {
        let param = FRParams()
        param.referenceId = referenceId
        param.selfieImage = selfieImg
        selfieImage = selfieImg
        veryfyKit.performFR(frInput: param)
        if flowType == .fr {
            thirdCircle.backgroundColor = K.Colors.completeColor
        }
    }
    
    func promptErrMsg(msg: String) {
        // Check if the session is already ended
        if sessionEnded {
            return
        }

        let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            if self.maxRetry == 0 {
                self.sessionEnded = true
                self.promptErrMsg(msg: "Maximum attempt reached")
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func showSelfieView() {
        resultIDView.removeFromSuperview()
        firstCircle.backgroundColor = K.Colors.completeColor
        secCircle.backgroundColor = K.Colors.pendingColor
        thirdCircle.backgroundColor = .white
        currentStepStatus = .selfiePending
        showCaptureView(type: .selfiePending)
    }
    
    func showFullResult() {
        self.showLoader()
        veryfyKit.performOCRFR(ocrFrInput: ocrFRParam)
    }
    
    func showFRResultView(result: FRModel?) {
        self.captureIDView.removeFromSuperview()
        self.resultIDView.removeFromSuperview()
        self.contentView.layoutIfNeeded()
        self.contentView.addSubview(self.resultFaceView)
        self.resultFaceView.delegate = self
        self.resultFaceView.parentVC = self
        self.selfieRetryCount += 1
        self.resultFaceView.initData(result, image: self.selfieImage)
        let trailingAnchor = self.resultFaceView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0)
        let leadingAnchor = self.resultFaceView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0)
        let topAnchor = self.resultFaceView.topAnchor.constraint(equalTo: self.logoutView.bottomAnchor, constant: 0)
        let bottomAnchor = self.resultFaceView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0)
        NSLayoutConstraint.activate([trailingAnchor, leadingAnchor, topAnchor, bottomAnchor])
        self.firstCircle.backgroundColor = K.Colors.completeColor
        self.secCircle.backgroundColor = K.Colors.completeColor
        self.thirdCircle.backgroundColor = K.Colors.completeColor
    }
    
    @objc func backToSelectionPage() {
        navigationController?.popToRootViewController(animated: true)
    }
}

extension OCRViewController: VeryfyDelegate {
    
    func journeyCompleted(withResult result: JourneyModel?, errCode: String, errMsg: String) {
        DispatchQueue.main.async {
            self.lblSesId.text = "Session ID: \(result?.sessionId ?? "")"
        }
        self.referenceId = result?.referenceId ?? ""
        self.maxRetry = result?.maxRetry ?? 0
//        print("result:\(result?.referenceId ?? "") \(result?.sessionId ?? "") \(errCode) \(errMsg)")
    }
    
    func ocrCompleted(withResult result: OCRModel?, errCode: String?, errMsg: String?) {
        self.maxRetry -= 1
        if errMsg != "" {
            DispatchQueue.main.async {
                self.hideLoader()
                self.promptErrMsg(msg: errMsg ?? "")
//                print("ocrCompleted failed:\(errMsg ?? "") \(errCode ?? "")")
            }
        } else {
            if let descriptionValuePairs = result?.ocrKeyValue {
                // Iterate through the description-value pairs
//                for (description, value) in descriptionValuePairs {
//                    print("Description: \(description)")
//                    print("Value: \(value)")
//                }
//                print("documenttype:\(result?.documentType ?? "") \(errCode ?? "") \(errMsg ?? "")")
            } else {
                print("No description-value pairs found in OCRModel. \(errCode ?? "") \(errMsg ?? "")")
            }
            ocrModel = result
            DispatchQueue.main.async {
                self.showOCRResult()
                self.hideLoader()
            }
        }
    }

    func frCompleted(withResult result: FRModel?, errCode: String, errMsg: String) {
        self.maxRetry -= 1
//        print("frmodel:\(result?.probability ?? 0.0) \(result?.quality ?? 0.0) \(result?.score ?? 0.0) \(errCode) \(errMsg)")
        if errMsg != "" {
            DispatchQueue.main.async {
                self.promptErrMsg(msg: errMsg)
                self.hideLoader()
            }
        } else {
            DispatchQueue.main.async {
                self.hideLoader()
                self.showFRResultView(result: result)
            }
        } 
    }
    
    public func ocrFRCompleted(withOCRResult result: OCRModel?, frResult: FRModel?, errCode: String, errMsg: String) {
//        print("ocrfrcompleted:\(errCode) \(errMsg)")
        ocrModel = result
        frModel = frResult
        if errMsg == "" {
            DispatchQueue.main.async {
                self.showOCRResult()
            }
        } else {
            DispatchQueue.main.async {
                self.promptErrMsg(msg: errMsg)
            }
        }
    }
}

extension OCRViewController: CaptureViewDelegate {
    func getOCRResult(frontImg: Data, backImg: Data, frontImgFlash: Data, isFlash: Bool) {
        let param = OCRParams()
        param.backImage = backImg
        param.frontImage = frontImg
        param.frontImageFlash = frontImgFlash
        param.referenceId = referenceId
        if isFlash == false {
            param.imageType = 0
        } else {
            param.imageType = 1
        }
        if flowType == .ocr {
            promptConfirmAlert(.idPending, ocrInput: param, frInput: nil, isFlash: isFlash)
        } else {
            ocrFRParam.backImage = backImg
            ocrFRParam.frontImage = frontImg
            ocrFRParam.frontImageFlash = frontImgFlash
            ocrFRParam.referenceId = referenceId
            ocrFRParam.imageType = param.imageType
            promptFullFlowAlert(.selfiePending)
        }
    }
    
    func getFRResult(selfieImg: Data) {
        let param = FRParams()
        param.referenceId = referenceId
        param.selfieImage = selfieImg
        self.selfieImage = selfieImg
        if flowType == .fr {
            promptConfirmAlert(.selfiePending, ocrInput: nil, frInput: param, isFlash: false)
        } else {
            ocrFRParam.selfieImage = selfieImg
            promptFullFlowAlert(.completed)
        }
    }
}

extension OCRViewController: IDResultViewDelegate {
    func navRetry() {
        showScanID()
    }
    
    func doneOCR() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func showFRResult() {
        self.showFRResultView(result: frModel)
    }
}
extension OCRViewController: SelfieResultViewDelegate {
    func retrySelfie() {
        showSelfieView()
    }
    
    func retryOCRFR() {
        showScanID()
    }
}
