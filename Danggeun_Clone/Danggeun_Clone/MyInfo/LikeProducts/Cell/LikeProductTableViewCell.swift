//
//  LikeProductTableViewCell.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/02/13.
//

import UIKit

// MARK: [Class or Struct] ----------
class LikeProductTableViewCell: UITableViewCell {

    // MARK: [@IBOutlet] ----------
    @IBOutlet var thumbnailImageView: UIImageView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var finishedLabel: UILabel!
    @IBOutlet var reservationLabel: UILabel!

    @IBOutlet var likeCountLabel: UILabel!
    
    @IBOutlet var likeCountStackView: UIStackView!
    
    @IBOutlet var likeButton: UIButton!
    
    // MARK: [Override] ----------
    override func prepareForReuse() {
        finishedLabel.isHidden = true
        reservationLabel.isHidden = true
        likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        likeButton.tintColor = .darkGray
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        thumbnailImageView.layer.cornerRadius = 5
        
        finishedLabel.clipsToBounds = true
        finishedLabel.layer.cornerRadius = 3
        
        reservationLabel.clipsToBounds = true
        reservationLabel.layer.cornerRadius = 3
    }
}
