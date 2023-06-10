//
//  HiddenProductTableViewCell.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/02/13.
//

import UIKit

class HiddenProductTableViewCell: UITableViewCell {

    @IBOutlet var productImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var completedLabel: UILabel!
    @IBOutlet var reservationLabel: UILabel!

    @IBOutlet var likeCountLabel: UILabel!
    @IBOutlet var likeCountStackView: UIStackView!
    
    @IBOutlet var moreMenuButton: UIButton!
    
    @IBOutlet var hiddenButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        productImageView.layer.cornerRadius = 5
        
        completedLabel.clipsToBounds = true
        completedLabel.layer.cornerRadius = 3
        
        reservationLabel.clipsToBounds = true
        reservationLabel.layer.cornerRadius = 3
        
        hiddenButton.layer.borderWidth = 1
        hiddenButton.layer.borderColor = UIColor.systemGray6.cgColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        completedLabel.isHidden = true
        reservationLabel.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0))
    }

}
