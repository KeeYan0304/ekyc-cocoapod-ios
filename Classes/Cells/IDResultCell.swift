//
//  IDResultCell.swift
//  VeryFy
//
//  Created by Kee Chun Yan on 04/04/2023.
//

import UIKit

class IDResultCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var txtView: UITextView!

    var idModel: IDResultModel? {
        didSet{
            configure()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        txtView.layer.cornerRadius = 5
        backgroundColor = .clear
        txtView.isEditable = false
        txtView.isSelectable = false
        txtView.font = UIFont.systemFont(ofSize: 14.0)
        txtView.translatesAutoresizingMaskIntoConstraints = false
        txtView.isScrollEnabled = false
//        txtView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure() {
        lblName.text = idModel?.description?.uppercased()
        txtView.text = idModel?.value?.uppercased()
//        let size = txtView.sizeThatFits(CGSize(width: txtView.frame.width, height: CGFloat.greatestFiniteMagnitude))
//        let requiredHeight = size.height
//        textViewHeightConstant.constant = requiredHeight
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size = txtView.sizeThatFits(CGSize(width: txtView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        txtView.frame.size.height = size.height
    }

}
