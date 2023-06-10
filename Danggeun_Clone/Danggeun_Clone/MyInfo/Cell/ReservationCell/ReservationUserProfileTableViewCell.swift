//
//  ReservationUserTableViewCell.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/08/16.
//

import UIKit

class ReservationUserProfileTableViewCell: UITableViewCell {

    @IBOutlet var profileImageView: UIImageView!
    
    @IBOutlet var nicknameLabel: UILabel!
    
    @IBOutlet var addressLabel: UILabel!
    
    @IBOutlet var timeLabel: UILabel!
    
    @IBOutlet var profileImageViewHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageViewHeightConstraint.constant = UIScreen.main.bounds.height * 5 / 100
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
