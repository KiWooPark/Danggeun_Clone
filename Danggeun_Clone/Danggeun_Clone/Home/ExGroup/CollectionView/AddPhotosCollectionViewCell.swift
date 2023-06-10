//
//  AddPhotosCollectionViewCell.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/05/17.
//

import UIKit

class AddPhotosCollectionViewCell: UICollectionViewCell {
   
    @IBOutlet var addPhotoBackgroundView: UIView!
    @IBOutlet var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addPhotoBackgroundView.layer.borderWidth = 1.0
        addPhotoBackgroundView.layer.borderColor = UIColor.gray.cgColor
        addPhotoBackgroundView.layer.cornerRadius = 3
        
    }
}
