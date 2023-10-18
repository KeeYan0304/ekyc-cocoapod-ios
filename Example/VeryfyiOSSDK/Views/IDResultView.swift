//
//  IDResultView.swift
//  VeryFy
//
//  Created by Kee Chun Yan on 04/04/2023.
//
protocol IDResultViewDelegate: AnyObject {
    func navRetry()
    func doneOCR()
    func showFRResult()
}

import UIKit
import VeryfyiOSSDK

class IDResultView: UIView {
    let kCONTENT_XIB_NAME = "IDResultView"
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var retryView: UIView!
    
    @IBOutlet weak var nextView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var lblDone: UILabel!
    private let reuseIdentifer = "idResultCell"
    
    weak var delegate: IDResultViewDelegate?
    
    weak var parentVC: OCRViewController?
    
    var respModel = [IDResultModel]()
    
    @IBOutlet weak var parentTableHeight: NSLayoutConstraint!
    
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
        containerView.backgroundColor = K.Colors.outerBgColor
        holderView.backgroundColor = K.Colors.imageBgColor
        let resCell = UINib(nibName: "IDResultCell", bundle: nil)
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
    
    func setupBtns() {
        let tapRetry = UITapGestureRecognizer(target: self, action: #selector(retryCapture))
        retryView.addGestureRecognizer(tapRetry)
        retryView.isUserInteractionEnabled = true
        if parentVC?.flowType == .ocr {
            let tapDone = UITapGestureRecognizer(target: self, action: #selector(ocrCompleted))
            nextView.addGestureRecognizer(tapDone)
            lblDone.text = "Done"
            retryView.isHidden = false
        } else if parentVC?.flowType == .full{
            let tapShowFRResult = UITapGestureRecognizer(target: self, action: #selector(showFRResult))
            nextView.addGestureRecognizer(tapShowFRResult)
            lblDone.text = "Next"
            retryView.isHidden = true
        }
        nextView.isUserInteractionEnabled = true
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
    
    @objc func retryCapture() {
        delegate?.navRetry()
        retryView.isUserInteractionEnabled = false
        retryView.backgroundColor = K.Colors.disableColor
    }
    
    @objc func ocrCompleted() {
        delegate?.doneOCR()
    }
    
    @objc func showFRResult() {
        delegate?.showFRResult()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        parentTableHeight.constant = tableView.contentSize.height
        mainView.layoutIfNeeded()
    }
}
extension IDResultView: UITableViewDelegate, UITableViewDataSource {
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
