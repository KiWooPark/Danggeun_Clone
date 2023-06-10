//
//  OtherProductCollectionViewCell.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/01/14.
//

import UIKit

// MARK: [Class or Struct] ----------
class OtherProductCollectionViewCell: UICollectionViewCell {
    
    // MARK: [@IBOutlet] ----------
    @IBOutlet var productImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    
    // MARK: [Override] ----------
    override func awakeFromNib() {
        productImageView.layer.cornerRadius = 5
    }
    
}
