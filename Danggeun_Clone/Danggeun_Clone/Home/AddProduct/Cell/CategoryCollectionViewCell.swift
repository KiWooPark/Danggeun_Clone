//
//  CategoryCollectionViewCell.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/02/03.
//

import UIKit

// MARK: [Class or Struct] ----------
class CategoryCollectionViewCell: UICollectionViewCell {
    
    // MARK: [@IBOutlet] ----------
    @IBOutlet var categoryNameLabel: UILabel!
    
    // MARK: [Override] ----------

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderColor = UIColor.systemGray4.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 15
    }
}
