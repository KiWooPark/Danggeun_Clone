//
//  AddPhotoCollectionViewCell.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/02/04.
//

import UIKit

// MARK: [Class or Struct] ----------
class AddPhotoCollectionViewCell: UICollectionViewCell {
    
    // MARK: [@IBOutlet] ----------
    @IBOutlet var countLabel: UILabel!
    @IBOutlet var addPhotoCellBackgroundView: UIView!
    
    // MARK: [Override] ----------
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addPhotoCellBackgroundView.layer.borderWidth = 1
        addPhotoCellBackgroundView.layer.borderColor = UIColor.systemGray6.cgColor
        addPhotoCellBackgroundView.layer.cornerRadius = 5
    }
}
