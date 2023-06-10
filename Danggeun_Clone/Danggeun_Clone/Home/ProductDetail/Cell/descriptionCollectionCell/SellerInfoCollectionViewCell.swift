//
//  SellerInfoCollectionViewCell.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/01/14.
//

import UIKit

// MARK: [Class or Struct] ----------
class SellerInfoCollectionViewCell: UICollectionViewCell {

    // MARK: [@IBOutlet] ----------
    @IBOutlet var nickNameLabel: UILabel!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var addressLabel: UILabel!
    
    // MARK: [Override] ----------
    override func awakeFromNib() {
        profileImageView.layer.cornerRadius = 50 / 2
    }
}

