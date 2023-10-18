//
//  LabelResultCell.swift
//  VeryFy
//
//  Created by Kee Chun Yan on 05/04/2023.
//

import UIKit

class LabelResultCell: UITableViewCell {

    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
