//
//  CameraView.swift
//  VeryFy
//
//  Created by Kee Chun Yan on 29/08/2023.
//

import UIKit
import AVFoundation

enum CameraType {
    case Front
    case Back
}

protocol CameraViewDelegate: AnyObject {
    func dismissView()
    func useImage(image: UIImage)
}

class CameraView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var lblCancel: UILabel!
    @IBOutlet weak var captureImg: UIImageView!
    @IBOutlet weak var flipImg: UIImageView!
    @IBOutlet weak var toggleFlashImg: UIImageView!
    @IBOutlet weak var previewImg: UIImageView!
    @IBOutlet weak var retakeView: UIView!
    @IBOutlet weak var lblRetake: UILabel!
    @IBOutlet weak var lblUsePhoto: UILabel!
    
    let flashOnImg = UIImage(named: "flash_on_icon")
    
    let flashOffImg = UIImage(named: "flash_off_icon")
    
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    var cameraType = CameraType.Back
    
    var captureType: ContentType?
    
    var captureSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
    
    var isFlashOn = false // Track flash mode
    
    weak var delegate: CameraViewDelegate?
    
    weak var parentVC: OCRViewController?
    
    let cardGuideImg = UIImageView()
    
    let kCONTENT_XIB_NAME = "CameraView"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
        initCameraView()
    }
    
    func initCameraView() {
        topView.backgroundColor = UIColor.init(white: 0.1, alpha: 0.3)
        bottomView.backgroundColor = UIColor.init(white: 0.1, alpha: 0.3)
        retakeView.backgroundColor = UIColor.init(white: 0.1, alpha: 0.3)
        let tapCancel = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        lblCancel.addGestureRecognizer(tapCancel)
        lblCancel.isUserInteractionEnabled = true
        toggleFlashImg.image = flashOffImg
        let flashGesture = UITapGestureRecognizer(target: self, action: #selector(toggleFlash))
        toggleFlashImg.addGestureRecognizer(flashGesture)
        toggleFlashImg.isUserInteractionEnabled = true
        let flipGesture = UITapGestureRecognizer(target: self, action: #selector(toggleFlip))
        flipImg.addGestureRecognizer(flipGesture)
        flipImg.isUserInteractionEnabled = true
        let tapCapture = UITapGestureRecognizer(target: self, action: #selector(takePic))
        captureImg.addGestureRecognizer(tapCapture)
        captureImg.isUserInteractionEnabled = true
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        previewImg.isHidden = true
        retakeView.isHidden = true
        let tapRetake = UITapGestureRecognizer(target: self, action: #selector(retakePic))
        lblRetake.addGestureRecognizer(tapRetake)
        lblRetake.isUserInteractionEnabled = true
        let tapUsePhoto = UITapGestureRecognizer(target: self, action: #selector(usePhoto))
        lblUsePhoto.addGestureRecognizer(tapUsePhoto)
        lblUsePhoto.isUserInteractionEnabled = true
    }
    
    @objc func retakePic() {
        addGuideBorder()
        previewImg.isHidden = true
        retakeView.isHidden = true
        bottomView.isHidden = false
    }
    
    @objc func usePhoto() {
        delegate?.useImage(image: previewImg.image ?? UIImage())
        dismissView()
    }
    
    func addGuideBorder() {
        var imageName: String = ""
        if captureType == .selfie {
            imageName = "selfie_guide_line"
        } else {
            imageName = "card_guide_line"
        }
        cardGuideImg.image = UIImage(named: imageName)
        if captureType == .selfie {
            cardGuideImg.image = UIImage(named: "selfie_guide_line")
        } else {
            cardGuideImg.image = UIImage(named: "card_guide_line")
        }
        var imageSize = cardGuideImg.image?.size ?? CGSize.zero
        
        if imageName == "selfie_guide_line" {
            let scale: CGFloat = 1.8 // Adjust the scale factor as needed
            imageSize.width *= scale
            imageSize.height *= scale
        }
        
        // Calculate the frame to center the image view
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let xOffset = (screenWidth - imageSize.width) / 2
        let yOffset = (screenHeight - imageSize.height) / 2
        
        cardGuideImg.frame = CGRect(x: xOffset, y: yOffset, width: imageSize.width, height: imageSize.height)
        
        parentVC?.view.addSubview(cardGuideImg)
        parentVC?.view.bringSubview(toFront: cardGuideImg)
    }
    
    func initializeCamera(type: ContentType) {
        captureType = type
        if captureType == .selfie {
            cameraType = .Front
        } else {
            cameraType = .Back
        }
        guard let captureDevice = getCaptureDevice(for: cameraType) else {
            print("Unable to access the specified camera!")
            return
        }
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            stillImageOutput = AVCapturePhotoOutput()
            
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
            }
            
        }
        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
    }
    
    func getCaptureDevice(for cameraType: CameraType) -> AVCaptureDevice? {
        switch cameraType {
        case .Front:
            return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        case .Back:
            return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        }
    }
    
    @objc func dismissView() {
        self.captureSession.stopRunning()
        delegate?.dismissView()
        removeFromSuperview()
        cardGuideImg.removeFromSuperview()
    }
    
    @objc func toggleFlash() {
        // Toggle the flash status
        isFlashOn.toggle()
        
        // Update the flash mode based on the current state of isFlashOn
        if isFlashOn {
            captureSettings.flashMode = .on
            toggleFlashImg.image = flashOnImg
        } else {
            captureSettings.flashMode = .off
            toggleFlashImg.image = flashOffImg
        }
    }
    
    func setupLivePreview() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(videoPreviewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.previewView.bounds
                self.addGuideBorder()
            }
        }
    }

    @objc func toggleFlip() {
        guard let captureSession = self.captureSession else { return }
        
        captureSession.beginConfiguration()
        
        for input in captureSession.inputs {
            if let deviceInput = input as? AVCaptureDeviceInput, deviceInput.device.hasMediaType(.video) {
                let device = deviceInput.device
                if device.position == .back {
                    if let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                        do {
                            let newInput = try AVCaptureDeviceInput(device: frontCamera)
                            captureSession.removeInput(deviceInput)
                            if captureSession.canAddInput(newInput) {
                                captureSession.addInput(newInput)
                            }
                            cameraType = .Front
                        } catch {
                            print("Error switching to front camera: \(error.localizedDescription)")
                        }
                    }
                } else if device.position == .front {
                    if let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                        do {
                            let newInput = try AVCaptureDeviceInput(device: backCamera)
                            captureSession.removeInput(deviceInput)
                            if captureSession.canAddInput(newInput) {
                                captureSession.addInput(newInput)
                            }
                            cameraType = .Back
                        } catch {
                            print("Error switching to back camera: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
        
        captureSession.commitConfiguration()
    }
    
    @objc func takePic() {
        let captureSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        if cameraType == .Back {
            // Set the flash mode based on the current state of isFlashOn
            if isFlashOn {
                captureSettings.flashMode = .on
            } else {
                captureSettings.flashMode = .off
            }
        } else {
            // Set the flash mode based on the current state of isFlashOn
            captureSettings.flashMode = .off
        }
        stillImageOutput.capturePhoto(with: captureSettings, delegate: self)
        
    }
}
extension CameraView: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation()
             else { return }
         
        guard let image = UIImage(data: imageData) else {return}
        previewImg.image = image
        previewImg.isHidden = false
        cardGuideImg.removeFromSuperview()
        bottomView.isHidden = true
        retakeView.isHidden = false
    }
}
