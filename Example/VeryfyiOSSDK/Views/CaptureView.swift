//
//  CaptureView.swift
//  VeryFy
//
//  Created by Kee Chun Yan on 04/04/2023.
//

import UIKit
import AVFoundation
import VeryfyiOSSDK

//import IDCardCamera

protocol CaptureViewDelegate: AnyObject {
    func getOCRResult(frontImg: Data, backImg: Data, frontImgFlash: Data, isFlash: Bool)
    func getFRResult(selfieImg: Data)
}

enum ContentType {
    case front
    case back
    case selfie
    case flash
    case none
}

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

class CaptureView: UIView {
    let kCONTENT_XIB_NAME = "CaptureView"
    
    @IBOutlet weak var backImg: UIImageView!
    @IBOutlet weak var frontImg: UIImageView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var frontBtnView: UIView!
    @IBOutlet weak var flashBtnView: UIView!
    @IBOutlet weak var backBtnView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var lblBtn1: UILabel!
    @IBOutlet weak var lblBtn2: UILabel!
    @IBOutlet weak var stackView1: UIStackView!
    @IBOutlet weak var stackView2: UIStackView!
    @IBOutlet weak var frontImgHeight: NSLayoutConstraint!
    @IBOutlet weak var docView: UIView!
    @IBOutlet weak var docTableView: UITableView!
    @IBOutlet weak var lblSelectedDoc: UILabel!
    @IBOutlet weak var attentionView: UIView!
    @IBOutlet weak var lblAttention: UILabel!
    @IBOutlet weak var lblAttentionDesc: UILabel!
    @IBOutlet weak var frontImgFlash: UIImageView!
    @IBOutlet weak var stackView3: UIStackView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    lazy var cameraView: CameraView = {
        let view = CameraView()
        return view
    }()
    
    private let reuseIdentifer = "labelCell"
    
    var picType = ContentType.none
    let imgPicker1 = UIImagePickerController()
    
    weak var delegate: CaptureViewDelegate?
    
    weak var parentVC: OCRViewController?
    
    let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    
    var docType: DocType = .none
    
    var frontImage = UIImage()
    var backImage = UIImage()
    var frontImageFlash = UIImage()
    
    var docName = ["Driving License", "SSS", "UMID", "National ID", "Passport", "PRC", "Voter's ID", "Postal ID"]
    
    let cardGuideImg = UIImageView()

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
        frontImg.backgroundColor = K.Colors.imageBgColor
        backImg.backgroundColor = K.Colors.imageBgColor
        frontImgFlash.backgroundColor = K.Colors.imageBgColor
        backBtnView.layer.cornerRadius = backBtnView.frame.height / 2
        frontBtnView.layer.cornerRadius = frontBtnView.frame.height / 2
        flashBtnView.layer.cornerRadius = flashBtnView.frame.height / 2
        backBtnView.clipsToBounds = true
        frontBtnView.clipsToBounds = true
        flashBtnView.clipsToBounds = true
        frontImg.backgroundColor = K.Colors.imageBgColor
        backImg.backgroundColor = K.Colors.imageBgColor
        frontImgFlash.backgroundColor = K.Colors.imageBgColor
        containerView.backgroundColor = K.Colors.outerBgColor
        let tapDocView = UITapGestureRecognizer(target: self, action: #selector(selectDocList))
        docView.addGestureRecognizer(tapDocView)
        docView.isUserInteractionEnabled = true
        docView.layer.borderWidth = 0.5
        docView.layer.borderColor = UIColor.lightGray.cgColor
        
        let resCell = UINib(nibName: "LabelResultCell", bundle: nil)
        docTableView.register(resCell, forCellReuseIdentifier: reuseIdentifer)
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
        cardGuideImg.image = UIImage(named: "card_guide_line")
    }
    
    func checkCameraPermission() {
        switch cameraAuthorizationStatus {
        case .notDetermined:
            // Request permission to access the camera
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
//                        self.presentImagePicker(sourceType: .camera)
                        print("checkCameraPermission: granted")
                        self.promptCameraView()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.promptCameraReminder()
                        print("checkCameraPermission: not granted")
                    }
                }
            }
        case .authorized:
            DispatchQueue.main.async {
//                self.presentImagePicker(sourceType: .camera)
                self.promptCameraView()
                print("checkCameraPermission: authorized")
            }
            break
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.promptCameraReminder()
                print("checkCameraPermission: denied")
            }
            break
        @unknown default:
            // Handle future authorization status cases
            break
        }
    }
    
    func promptCameraView() {
        parentVC?.showCameraView()
        parentVC?.cameraView.delegate = self
    }
    
    func setupImgPicker() {
        imgPicker1.delegate = self
        imgPicker1.sourceType = .camera
        frontBtnView.isUserInteractionEnabled = true
        backBtnView.isUserInteractionEnabled = true
        flashBtnView.isUserInteractionEnabled = true
    }
    
    func initBtns() {
        frontBtnView.gestureRecognizers?.removeAll()
        backBtnView.gestureRecognizers?.removeAll()
        flashBtnView.gestureRecognizers?.removeAll()
        frontImg.translatesAutoresizingMaskIntoConstraints = false
        var capFront = UITapGestureRecognizer()
        var capBack = UITapGestureRecognizer()
        var capFlash = UITapGestureRecognizer()
        if picType != .selfie {
            capFront = UITapGestureRecognizer(target: self, action: #selector(captureFront))
            capBack = UITapGestureRecognizer(target: self, action: #selector(captureBack))
            capFlash = UITapGestureRecognizer(target: self, action: #selector(captureFlash))
            frontImgHeight.constant = 180
            setupDocUI()
        } else {
            capFront = UITapGestureRecognizer(target: self, action: #selector(captureSelfie))
            frontImgHeight.constant = 400
            setupSelfieUI()
        }
        frontBtnView.addGestureRecognizer(capFront)
        backBtnView.addGestureRecognizer(capBack)
        flashBtnView.addGestureRecognizer(capFlash)
        frontImg.contentMode = .scaleToFill
        backImg.contentMode = .scaleToFill
        frontImgFlash.contentMode = .scaleToFill
    }
    
    @objc func captureFront() {
        if parentVC?.maxRetry == 0 {
            self.parentVC?.promptErrMsg(msg: "Maximum attempt reached")
            return
        }
        picType = .front
        checkCameraPermission()
    }
    
    @objc func captureBack() {
        if parentVC?.maxRetry == 0 {
            self.parentVC?.promptErrMsg(msg: "Maximum attempt reached")
            return
        }
        picType = .back
        checkCameraPermission()
    }
    
    @objc func captureFlash() {
        if parentVC?.maxRetry == 0 {
            self.parentVC?.promptErrMsg(msg: "Maximum attempt reached")
            return
        }
        picType = .flash
        checkCameraPermission()
    }
    
    @objc func captureSelfie() {
        if parentVC?.maxRetry == 0 {
            self.parentVC?.promptErrMsg(msg: "Maximum attempt reached")
            return
        }
        picType = .selfie
        checkCameraPermission()
    }
    
    func promptCameraReminder() {
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
    
    @objc func selectDocList() {
        docTableView.isHidden = false
    }
    
    func setupDocUI() {
        lblBtn1.text = "Capture ID Front"
        topConstraint.constant = 80
        docView.isHidden = false
        stackView1.isHidden = false
        if docType == .driver || docType == .sss || docType == .umid {
            stackView2.isHidden = false
            lblBtn2.text = "Capture ID Front (Flash On)"
        } else if docType == .none {
            stackView1.isHidden = true
            stackView2.isHidden = true
            stackView3.isHidden = true
        }
        else {
            stackView2.isHidden = true
            stackView3.isHidden = true
        }
        attentionView.backgroundColor = K.Colors.attentionColor
        lblAttention.textColor = K.Colors.headerAttentionColor
        lblAttentionDesc.textColor = K.Colors.headerAttentionColor
        lblAttention.font = UIFont.boldSystemFont(ofSize: 25)
        lblAttentionDesc.text = "You are required to take the front image of this document ID type with the camera flash on."
    }
    
    func setupSelfieUI() {
        topConstraint.constant = 20
        lblBtn1.text = "Capture Selfie"
        self.stackView1.isHidden = false
        docView.isHidden = true
        stackView2.isHidden = true
        stackView3.isHidden = true
    }
}
extension CaptureView: UIImagePickerControllerDelegate & UINavigationControllerDelegate {

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
            self.stackView3.isHidden = false
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { _ in
            let frontData = self.resizeImageAndLimitFileSize(image: self.frontImg.image ?? UIImage())
            let fC = Double(frontData?.count ?? 0) / (1024 * 1024)
//            print("frontdata: \(fC)")
            self.delegate?.getOCRResult(frontImg: frontData ?? Data(), backImg: Data(), frontImgFlash: Data(), isFlash: !self.stackView2.isHidden)
        }))
        self.parentVC?.present(alert, animated: true, completion: nil)
    }
}

extension CaptureView: CropperViewControllerDelegate {

    func cropperDidConfirm(_ cropper: CropperViewController, state: CropperState?) {
        if let state = state,
           let image = cropper.originalImage.cropped(withCropperState: state) {
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
                        self.delegate?.getOCRResult(frontImg: frontData ?? Data(), backImg: backData ?? Data(), frontImgFlash: frontFlashData ?? Data(), isFlash: !self.stackView2.isHidden)
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
        cropper.dismiss(animated: true) {
            self.cameraView.dismissView()
        }
    }
}

extension CaptureView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return docName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifer, for: indexPath) as! LabelResultCell
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
extension CaptureView: CameraViewDelegate {
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
