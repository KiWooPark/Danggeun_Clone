//
//  ProfileTableViewCell.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/02/10.
//

import UIKit

// MARK: [Class or Struct] ----------
class ProfileTableViewCell: UITableViewCell {
    
    // MARK: [@IBOutlet] ----------
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var nicknameLabel: UILabel!
    @IBOutlet var showProfileButton: UIButton!
    
    // MARK: [Override] ----------
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = 75 / 2
        showProfileButton.layer.cornerRadius = 5
    }
}
