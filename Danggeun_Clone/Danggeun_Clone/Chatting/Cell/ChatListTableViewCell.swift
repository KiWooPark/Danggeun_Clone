//
//  ChatListTableViewCell.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/06/24.
//

import UIKit

class ChatListTableViewCell: UITableViewCell {
    
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var regionLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        profileImageView.layer.cornerRadius = profileImageView.frame.width * 0.5
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        print("셀")
//        // Configure the view for the selected state
//    }

}
