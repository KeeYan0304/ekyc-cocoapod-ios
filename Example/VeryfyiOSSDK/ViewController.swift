//
//  ViewController.swift
//  VeryfyiOSSDK
//
//  Created by Kee Chun Yan on 10/17/2023.
//  Copyright (c) 2023 Kee Chun Yan. All rights reserved.
//

import UIKit
import VeryfyiOSSDK

class ViewController: UIViewController {

    let veryfyKit = VeryfyKit.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        veryfyKit.delegate = self
        veryfyKit.startJourney()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
extension ViewController: VeryfyDelegate {
    func journeyCompleted(withResult result: VeryfyiOSSDK.JourneyModel?, errCode: String, errMsg: String) {
        print("result:\(result) \(errCode) \(errMsg)")
    }
}

 
