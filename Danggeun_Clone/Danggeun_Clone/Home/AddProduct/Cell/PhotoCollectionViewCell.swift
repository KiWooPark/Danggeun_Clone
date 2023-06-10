//
//  PhotoCollectionViewCell.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/02/04.
//

import UIKit

// MARK: [Class or Struct] ----------
class PhotoCollectionViewCell: UICollectionViewCell {
    
    // MARK: [@IBOutlet] ----------
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var selectedImageView: UIImageView!
    @IBOutlet var representativeLabel: UILabel!
    
    // MARK: [Override] ----------
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectedImageView.layer.cornerRadius = 5
        
        representativeLabel.clipsToBounds = true
        representativeLabel.layer.cornerRadius = 5
        representativeLabel.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMaxYCorner, .layerMaxXMaxYCorner)
    }
}
