//
//  ProfileDataTableViewCell.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/02/16.
//

import UIKit

// MARK: [Class or Struct] ----------
class ProfileDataTableViewCell: UITableViewCell {
    
    // MARK: [@IBOutlet] ----------
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var nicknameLabel: UILabel!
    
    @IBOutlet var editProfileButton: UIButton!
    
    // MARK: [Override] ----------
    override func prepareForReuse() {
        super.prepareForReuse()
        
        editProfileButton.isHidden = false
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = 100 / 2
        editProfileButton.layer.cornerRadius = 10
    }
}
