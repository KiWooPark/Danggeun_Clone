//
//  InterestProductTableViewCell.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/09/06.
//

import UIKit

protocol InterestDelegate {
    func tapHeartButton(index: Int)
}

class InterestProductTableViewCell: UITableViewCell {

    @IBOutlet var productImageView: UIImageView!
    @IBOutlet var productTitleLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var finishedLabel: UILabel!
    @IBOutlet var reservationLabel: UILabel!
    
    @IBOutlet var likeButton: UIButton!
    
    @IBOutlet var chatImageView: UIImageView!
    @IBOutlet var heartImageView: UIImageView!
    
    @IBOutlet var chatCountLabel: UILabel!
    @IBOutlet var likeCountLabel: UILabel!
    
    var delegate: InterestDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    @IBAction func tapHeartButton(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        
        delegate?.tapHeartButton(index: button.tag)
    }
}
