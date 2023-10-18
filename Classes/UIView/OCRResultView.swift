//
//  OCRResultView.swift
//  VeryfyClientSDK
//
//  Created by Kee Chun Yan on 06/10/2023.
//

import UIKit

@objc protocol OCRResultViewDelegate: AnyObject {
    func navRetry()
    @objc optional func doneOCR()
    func showFRResult()
}

class OCRResultView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var retryView: UIView!
    
    @IBOutlet weak var nextView: UIView!
    @IBOutlet weak var lblDone: UILabel!
    @IBOutlet weak var parentTableHeight: NSLayoutConstraint!

    private let reuseIdentifer = "idResultCell"
    
    var respModel = [IDResultModel]()
    
    let kCONTENT_XIB_NAME = "OCRResultView"
    
    weak var delegate: OCRResultViewDelegate?
    
    weak var parentVC: EKYCViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        let sdkBundle = Bundle(for: OCRResultView.self)
        sdkBundle.loadNibNamed("OCRResultView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.backgroundColor = K.Colors.outerBgColor
        holderView.backgroundColor = K.Colors.imageBgColor
        let resCell = UINib(nibName: "IDResultCell", bundle: Bundle(for: VeryfyKit.self))
        tableView.register(resCell, forCellReuseIdentifier: reuseIdentifer)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.separatorInset = .zero
        tableView.separatorColor = .clear
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        retryView.backgroundColor = K.Colors.primaryColor
        tableView.backgroundColor = .clear
        nextView.backgroundColor = K.Colors.primaryColor
        retryView.layer.cornerRadius = retryView.frame.height/2
        nextView.layer.cornerRadius = nextView.frame.height/2
        retryView.clipsToBounds = true
        nextView.clipsToBounds = true
        tableView.bounces = false
    }

    func initData(_ model: OCRModel) {
        respModel.removeAll()
        let docModel = IDResultModel(description: "Document Type", value: model.documentType ?? "")
        respModel.append(docModel)
        if let descriptionValuePairs = model.ocrKeyValue {
            // Iterate through the description-value pairs
            for (description, value) in descriptionValuePairs {
//                print("Description: \(description)")
//                print("Value: \(value)")
                let model = IDResultModel(description: description, value: value)
                respModel.append(model)
            }
        }
//        print("respmodel:\(respModel.map {$0.description}) \(respModel.map {$0.value})")
        tableView.reloadData()
    }
    
    func setupBtns() {
        let tapRetry = UITapGestureRecognizer(target: self, action: #selector(retryCapture))
        retryView.addGestureRecognizer(tapRetry)
        retryView.isUserInteractionEnabled = true
        let tapShowFRResult = UITapGestureRecognizer(target: self, action: #selector(showFRResult))
        nextView.addGestureRecognizer(tapShowFRResult)
        lblDone.text = "Next"
        retryView.isHidden = true
        nextView.isUserInteractionEnabled = true
    }
    
    @objc func retryCapture() {
        delegate?.navRetry()
        retryView.isUserInteractionEnabled = false
        retryView.backgroundColor = K.Colors.disableColor
    }
    
    @objc func ocrCompleted() {
        delegate?.doneOCR?()
    }
    
    @objc func showFRResult() {
        delegate?.showFRResult()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        parentTableHeight.constant = tableView.contentSize.height
        containerView.layoutIfNeeded()
    }
}
extension OCRResultView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return respModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifer, for: indexPath) as! IDResultCell
        cell.idModel = respModel[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        layoutSubviews()
    }
}
