//
//  TradingProductTableViewCell.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/02/13.
//

import UIKit

class TradingProductTableViewCell: UITableViewCell {
    
    @IBOutlet var productImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var completedLabel: UILabel!
    @IBOutlet var reservationLabel: UILabel!

    @IBOutlet var likeCountLabel: UILabel!
    @IBOutlet var likeCountStackView: UIStackView!
    
    @IBOutlet var tradingButton: UIButton!
    @IBOutlet var reservationButton: UIButton!
    @IBOutlet var completedButton: UIButton!
    
    @IBOutlet var moreMenuButton: UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()

        productImageView.layer.cornerRadius = 5
        
        completedLabel.clipsToBounds = true
        completedLabel.layer.cornerRadius = 3
        
        reservationLabel.clipsToBounds = true
        reservationLabel.layer.cornerRadius = 3
        
        tradingButton.layer.borderWidth = 1
        reservationButton.layer.borderWidth = 1
        completedButton.layer.borderWidth = 1
        
        tradingButton.layer.borderColor = UIColor.systemGray6.cgColor
        reservationButton.layer.borderColor = UIColor.systemGray6.cgColor
        completedButton.layer.borderColor = UIColor.systemGray6.cgColor
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        completedLabel.isHidden = true
        reservationLabel.isHidden = true
        tradingButton.isHidden = false
        reservationButton.isHidden = false
        completedButton.isHidden = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0))
    }
}
