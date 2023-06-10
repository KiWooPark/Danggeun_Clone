//
//  ProductTableViewCell.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/10/28.
//

import UIKit

// MARK: [Class or Struct] ----------
class ProductTableViewCell: UITableViewCell {

    // MARK: [@IBOutlet] ----------
    @IBOutlet var productImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var finishedLabel: UILabel!
    @IBOutlet var reservationLabel: UILabel!

    @IBOutlet var likeImageView: UIImageView!
    @IBOutlet var likeCountLabel: UILabel!
    
    @IBOutlet var chatAndLikeStackView: UIStackView!
    @IBOutlet var productImageViewHeight: NSLayoutConstraint!
    
    // MARK: [Override] ----------
    override func prepareForReuse() {
        finishedLabel.isHidden = true
        reservationLabel.isHidden = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        productImageView.layer.cornerRadius = 5
        
        finishedLabel.clipsToBounds = true
        finishedLabel.layer.cornerRadius = 3
        
        reservationLabel.clipsToBounds = true
        reservationLabel.layer.cornerRadius = 3
    }
}
