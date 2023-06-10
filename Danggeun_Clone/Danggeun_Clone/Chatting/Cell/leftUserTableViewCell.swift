//
//  leftUserTableViewCell.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/06/24.
//

import UIKit

class leftUserTableViewCell: UITableViewCell {

    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var messageView: UIView!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageView.layer.cornerRadius = 10
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        print("셀")
//        // Configure the view for the selected state
//    }

}
