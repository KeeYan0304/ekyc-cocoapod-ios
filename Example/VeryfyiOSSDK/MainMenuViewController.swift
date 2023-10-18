//
//  MainMenuViewController.swift
//  VeryfyIntegrateSDK
//
//  Created by Kee Chun Yan on 29/09/2023.
//

import UIKit
import VeryfyiOSSDK

class MainMenuViewController: UIViewController {

    @IBOutlet weak var ocrView: UIView!
    @IBOutlet weak var frView: UIView!
    @IBOutlet weak var frameworkView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapOCR = UITapGestureRecognizer(target: self, action: #selector(navToOCR))
        ocrView.addGestureRecognizer(tapOCR)
        let tapFR = UITapGestureRecognizer(target: self, action: #selector(navToFR))
        frView.addGestureRecognizer(tapFR)
        let tapKit = UITapGestureRecognizer(target: self, action: #selector(navFramework))
        frameworkView.addGestureRecognizer(tapKit)
        ocrView.isUserInteractionEnabled = true
        frView.isUserInteractionEnabled = true
        frameworkView.isUserInteractionEnabled = true
    }

    @objc func navToOCR() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OCRViewController") as! OCRViewController
        vc.flowType = .ocr        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func navToFR() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OCRViewController") as! OCRViewController
        vc.flowType = .fr
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func navFramework() {
        if let sdkViewController = VeryfyKit.loadEKYCViewController(delegate: self) as? EKYCViewController {
            navigationController?.pushViewController(sdkViewController, animated: true)
        }
    }
}

extension MainMenuViewController: EKYCViewControllerDelegate {
    func eKYCViewControllerDidSessionEnded(_ viewController: EKYCViewController) {
        navigationController?.popToRootViewController(animated: true)
    }
}
