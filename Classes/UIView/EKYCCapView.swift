//
//  EKYCCapView.swift
//  VeryfyClientSDK
//
//  Created by Kee Chun Yan on 02/10/2023.
//

import UIKit
import AVFoundation

enum DocType {
    case passport
    case postal
    case sss
    case national
    case driver
    case umid
    case voter
    case prc
    case none
}

enum ContentType {
    case front
    case back
    case selfie
    case flash
    case none
}

protocol CaptureViewDelegate: AnyObject {
    func getOCRResult(frontImg: Data, backImg: Data, frontImgFlash: Data, isFlash: Bool)
    func getFRResult(selfieImg: Data)
}

class EKYCCapView: UIView {
    
    let kCONTENT_XIB_NAME = "EKYCCapView"
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var warningImg: UIImageView!
    @IBOutlet weak var lblSelectedDoc: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    private let warning_image = UIImage(named: "warning_icon", in: Bundle(for: EKYCCapView.self), compatibleWith: nil)
    
    private let docName = ["Driving License", "SSS", "UMID", "National ID", "Passport", "PRC", "Voter's ID", "Postal ID" ]
    @IBOutlet weak var docTableView: UITableView!
    @IBOutlet weak var docView: UIView!
    @IBOutlet weak var lblAttention: UILabel!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var attentionView: UIView!
    @IBOutlet weak var frontStackView: UIStackView!
    @IBOutlet weak var backStackView: UIStackView!
    @IBOutlet weak var flashStackView: UIStackView!
    @IBOutlet weak var lblBtn2: UILabel!
    @IBOutlet weak var lblAttentionDesc: UILabel!
    @IBOutlet weak var frontImg: UIImageView!
    @IBOutlet weak var backImg: UIImageView!
    @IBOutlet weak var frontImgFlash: UIImageView!
    @IBOutlet weak var captureFrontBtn: UIView!
    @IBOutlet weak var captureFlashBtn: UIView!
    @IBOutlet weak var captureBackBtn: UIView!
    @IBOutlet weak var frontImgHeight: NSLayoutConstraint!
    @IBOutlet weak var lblCaptureFront: UILabel!
    
    var docType: DocType = .none
    
    private let reuseIdentifier = "veryfyLabelCell"
    
    var picType = ContentType.none
//    let imgPicker1 = UIImagePickerController()
    
    weak var parentVC: EKYCViewController?
    
    let cardGuideImg = UIImageView()
    
    let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    
    weak var delegate: CaptureViewDelegate?
    
    var frontImage = UIImage()
    var backImage = UIImage()
    var frontImageFlash = UIImage()
    
    var cropperState: CropperState?
    
    lazy var cameraView: CameraView = {
        let view = CameraView()
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        let sdkBundle = Bundle(for: EKYCCapView.self)
        sdkBundle.loadNibNamed("EKYCCapView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        warningImg.image = warning_image
        frontImg.backgroundColor = K.Colors.imageBgColor
        backImg.backgroundColor = K.Colors.imageBgColor
        frontImgFlash.backgroundColor = K.Colors.imageBgColor
        captureBackBtn.layer.cornerRadius = captureBackBtn.frame.height / 2
        captureFlashBtn.layer.cornerRadius = captureFlashBtn.frame.height / 2
        captureFrontBtn.layer.cornerRadius = captureFrontBtn.frame.height / 2
        captureBackBtn.clipsToBounds = true
        captureFlashBtn.clipsToBounds = true
        captureFrontBtn.clipsToBounds = true
        frontImg.backgroundColor = K.Colors.imageBgColor
        backImg.backgroundColor = K.Colors.imageBgColor
        frontImgFlash.backgroundColor = K.Colors.imageBgColor
        containerView.backgroundColor = K.Colors.outerBgColor
        picType = .front
        initDocPicker()
        setupDocUI()
        setupImgPicker()
    }
    
    private func initDocPicker() {
        let tapDocView = UITapGestureRecognizer(target: self, action: #selector(selectDocList))
        docView.addGestureRecognizer(tapDocView)
        docView.isUserInteractionEnabled = true
        docView.layer.borderWidth = 0.5
        docView.layer.borderColor = UIColor.lightGray.cgColor
        let resCell = UINib(nibName: "VeryfyLabelCell", bundle: Bundle(for: VeryfyKit.self))
        docTableView.register(resCell, forCellReuseIdentifier: reuseIdentifier)
        docTableView.delegate = self
        docTableView.dataSource = self
        docTableView.isScrollEnabled = true
        docTableView.separatorInset = .zero
        docTableView.separatorColor = .clear
        docTableView.bounces = false
        docTableView.isHidden = true
        lblSelectedDoc.isHidden = true
        docTableView.layer.borderWidth = 0.5
        docTableView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    internal func setupDocUI() {
        topConstraint.constant = 80
        docView.isHidden = false
        frontStackView.isHidden = false
        if docType == .driver || docType == .sss || docType == .umid {
            backStackView.isHidden = false
            lblBtn2.text = "Capture ID Front (Flash On)"
        } else if docType == .none {
            frontStackView.isHidden = true
            backStackView.isHidden = true
            flashStackView.isHidden = true
        }
        else {
            backStackView.isHidden = true
            flashStackView.isHidden = true
        }
        attentionView.backgroundColor = K.Colors.attentionColor
        lblAttention.textColor = K.Colors.headerAttentionColor
        lblAttentionDesc.textColor = K.Colors.headerAttentionColor
        lblAttention.font = UIFont.boldSystemFont(ofSize: 25)
        lblAttentionDesc.text = "You are required to take the front image of this document ID type with the camera flash on."
    }
    
    private func setupImgPicker() {
//        imgPicker1.delegate = self
//        imgPicker1.sourceType = .camera
        captureFrontBtn.isUserInteractionEnabled = true
        captureBackBtn.isUserInteractionEnabled = true
        captureFlashBtn.isUserInteractionEnabled = true
        initBtns()
    }
    
    private func promptCameraView() {
        parentVC?.showCameraView()
        parentVC?.cameraView.delegate = self
    }
    
    internal func initBtns() {
        captureFrontBtn.gestureRecognizers?.removeAll()
        captureBackBtn.gestureRecognizers?.removeAll()
        captureFlashBtn.gestureRecognizers?.removeAll()
        frontImg.translatesAutoresizingMaskIntoConstraints = false
        var capFront = UITapGestureRecognizer()
        var capBack = UITapGestureRecognizer()
        var capFlash = UITapGestureRecognizer()
        if picType != .selfie {
            capFront = UITapGestureRecognizer(target: self, action: #selector(captureFront))
            capBack = UITapGestureRecognizer(target: self, action: #selector(captureBack))
            capFlash = UITapGestureRecognizer(target: self, action: #selector(captureFlash))
            frontImgHeight.constant = 180
        } else {
            capFront = UITapGestureRecognizer(target: self, action: #selector(captureSelfie))
            frontImgHeight.constant = 400
        }
        captureFrontBtn.addGestureRecognizer(capFront)
        captureBackBtn.addGestureRecognizer(capBack)
        captureFlashBtn.addGestureRecognizer(capFlash)
        frontImg.contentMode = .scaleToFill
        backImg.contentMode = .scaleToFill
        frontImgFlash.contentMode = .scaleToFill
    }
    
    @objc private func selectDocList() {
        docTableView.isHidden = false
    }
    
    @objc func captureFront() {
        if parentVC?.maxRetry == 0 {
            parentVC?.promptMaxLimit()
            return
        }
        picType = .front
        checkCameraPermission()
    }
    
    @objc func captureBack() {
        if parentVC?.maxRetry == 0 {
            parentVC?.promptMaxLimit()
            return
        }
        picType = .back
        checkCameraPermission()
    }
    
    @objc func captureFlash() {
        if parentVC?.maxRetry == 0 {
            parentVC?.promptMaxLimit()
            return
        }
        picType = .flash
        checkCameraPermission()
    }
    
    @objc func captureSelfie() {
        if parentVC?.maxRetry == 0 {
            parentVC?.promptMaxLimit()
            return
        }
        picType = .selfie
        checkCameraPermission()
    }
    
    func checkCameraPermission() {
        switch cameraAuthorizationStatus {
        case .notDetermined:
            // Request permission to access the camera
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
//                        self.presentImagePicker(sourceType: .camera)
//                        print("checkCameraPermission: granted")
                        self.promptCameraView()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.promptCameraReminder()
//                        print("checkCameraPermission: not granted")
                    }
                }
            }
        case .authorized:
            DispatchQueue.main.async {
//                self.presentImagePicker(sourceType: .camera)
                self.promptCameraView()
//                print("checkCameraPermission: authorized")
            }
            break
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.promptCameraReminder()
//                print("checkCameraPermission: denied")
            }
            break
        @unknown default:
            // Handle future authorization status cases
            break
        }
    }
    
    private func promptCameraReminder() {
        let alert = UIAlertController(
            title: "IMPORTANT",
            message: "Camera access required for performing E-KYC",
            preferredStyle: UIAlertController.Style.alert
        )
        alert.addAction(UIAlertAction(title: "Allow Camera", style: .default, handler: { (alert) -> Void in
            if let appSettings = NSURL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(appSettings as URL)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:  { (alert) -> Void in
           
        }))
        parentVC?.present(alert, animated: true, completion: nil)
    }
}
extension EKYCCapView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return docName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! VeryfyLabelCell
        cell.lblInfo.text = docName[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        layoutSubviews()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            docType = .driver
        } else if indexPath.row == 1 {
            docType = .sss
        } else if indexPath.row == 2 {
            docType = .umid
        } else if indexPath.row == 3 {
            docType = .national
        } else if indexPath.row == 4 {
            docType = .passport
        } else if indexPath.row == 5 {
            docType = .prc
        } else if indexPath.row == 6 {
            docType = .voter
        } else if indexPath.row == 7 {
            docType = .postal
        }
        lblSelectedDoc.text = docName[indexPath.row]
        docTableView.isHidden = true
        lblSelectedDoc.isHidden = false
        setupDocUI()
        frontImg.image = nil
        backImg.image = nil
        frontImgFlash.image = nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}
extension EKYCCapView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        if sourceType == .camera {
            imagePicker.cameraCaptureMode = .photo
            if picType == .selfie {
                imagePicker.cameraDevice = .front
            }
        }
        if let viewController = self.parentViewController {
            viewController.present(imagePicker, animated: true, completion: nil)
            if picType != .selfie {
                let imageSize = cardGuideImg.image?.size ?? CGSize.zero
                
                // Calculate the frame to center the image view
                let screenWidth = UIScreen.main.bounds.width
                let screenHeight = UIScreen.main.bounds.height
                
                let xOffset = (screenWidth - imageSize.width) / 2
                let yOffset = (screenHeight - imageSize.height) / 2
                
                cardGuideImg.frame = CGRect(x: xOffset, y: yOffset, width: imageSize.width, height: imageSize.height)
                
                // Add the custom view on top of the image picker
                imagePicker.view.addSubview(cardGuideImg)
                imagePicker.view.bringSubview(toFront: cardGuideImg)
            } else {
                
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: {
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage, let parentViewController = self.parentViewController {
                let cropper = CropperViewController(originalImage: image)

                cropper.delegate = self

                picker.dismiss(animated: true) {
                    parentViewController.present(cropper, animated: true, completion: nil)
                }
            }
        })
    }
    
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    func resizeImageAndLimitFileSize(image: UIImage) -> Data? {
        var compressionQuality: CGFloat = 0.2 // initial compression quality
        var imageData = UIImageJPEGRepresentation(image, compressionQuality)
        while let data = imageData, data.count > 300_000, compressionQuality > 0.0 {
            compressionQuality -= 0.1 // decrease the quality by 10%
            imageData = UIImageJPEGRepresentation(image, compressionQuality)
        }
        return imageData
    }
    
    func promptCaptureBackMsg() {
        let alert = UIAlertController(title: "ID Back", message: "Do you need to capture ID Back?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            self.backStackView.isHidden = false
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { _ in
            let frontData = self.resizeImageAndLimitFileSize(image: self.frontImg.image ?? UIImage())
            let fC = Double(frontData?.count ?? 0) / (1024 * 1024)
//            print("frontdata: \(fC)")
            self.delegate?.getOCRResult(frontImg: frontData ?? Data(), backImg: Data(), frontImgFlash: Data(), isFlash: !self.flashStackView.isHidden)
        }))
        self.parentVC?.present(alert, animated: true, completion: nil)
    }
}

extension EKYCCapView: CameraViewDelegate {
    func useImage(image: UIImage) {
        if let parentViewController = self.parentViewController {
            let cropper = CropperViewController(originalImage: image)
            cropper.delegate = self
            parentViewController.present(cropper, animated: true, completion: nil)
        }
    }
    
    func dismissView() {
        
    }
}
extension EKYCCapView: CropperViewControllerDelegate {
    
    func cropperDidConfirm(_ cropper: CropperViewController, state: CropperState?) {
        if let state = state,
           let image = cropper.originalImage.cropped(withCropperState: state) {
            cropperState = state
            if picType == .front {
                frontImg.image = image
                frontImage = image
            } else if picType == .back {
                backImg.image = image
                backImage = image
            } else if picType == .flash {
                frontImgFlash.image = image
                frontImageFlash = image
            } else {
                frontImg.image = image
                frontImage = image
            }
            frontImg.contentMode = .scaleAspectFit
            backImg.contentMode = .scaleAspectFit
            frontImgFlash.contentMode = .scaleAspectFit
            
            cropper.dismiss(animated: true, completion: {
                self.cameraView.dismissView()
                if self.picType != .selfie {
                    if self.picType == .front {
                        if self.docType != .driver && self.docType != .sss && self.docType != .umid {
                            if self.backImg.image == nil {
                                DispatchQueue.main.async {
                                    self.promptCaptureBackMsg()
                                }
                            } else {
                                self.picType = .flash
                            }
                        }
                    } else if self.picType == .flash {
                        DispatchQueue.main.async {
                            self.promptCaptureBackMsg()
                        }
                    }
                    else {
                        var frontData: Data?
                        var backData: Data?
                        var frontFlashData: Data?
                        frontData = self.resizeImageAndLimitFileSize(image: self.frontImage)
                        backData = self.resizeImageAndLimitFileSize(image: self.backImage)
                        frontFlashData = self.resizeImageAndLimitFileSize(image: self.frontImageFlash)
                        let fC = Double(frontData?.count ?? 0) / (1024 * 1024)
                        let bC = Double(backData?.count ?? 0) / (1024 * 1024)
                        let ffC = Double(frontFlashData?.count ?? 0) / (1024 * 1024)
//                        print("frontdata: \(fC) \(bC) \(ffC)")
                        self.delegate?.getOCRResult(frontImg: frontData ?? Data(), backImg: backData ?? Data(), frontImgFlash: frontFlashData ?? Data(), isFlash: !self.flashStackView.isHidden)
                    }
                } else {
                    let frontData = self.resizeImageAndLimitFileSize(image: self.frontImg.image ?? UIImage())
//                    print("selfieSize: \(String(describing: frontData?.count))")
                    self.delegate?.getFRResult(selfieImg: frontData ?? Data())
                }
            })
        }
    }
    
    func cropperDidCancel(_ cropper: CropperViewController) {
        cropper.dismiss(animated: true, completion: {
            self.cameraView.dismissView()
        })
    }
}
