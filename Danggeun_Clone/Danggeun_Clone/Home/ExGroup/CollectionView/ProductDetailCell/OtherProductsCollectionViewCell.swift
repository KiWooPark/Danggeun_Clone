//
//  OtherProductsCollectionViewCell.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/12/04.
//

import UIKit

class OtherProductsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var productImageView: UIImageView!
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        productImageView.layer.cornerRadius = 5
    }
}
