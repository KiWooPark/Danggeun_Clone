//
//  BoughtListTableViewCell.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/08/02.
//

import UIKit

protocol BoughtCellDelegate {
    func tapSendButton(index: Int, title: String)
    func tapBoughtAddButton(index: Int)
}

class BoughtListTableViewCell: UITableViewCell {
    
    @IBOutlet var productImageView: UIImageView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    
    @IBOutlet var timeLabel: UILabel!
    
    @IBOutlet var priceLabel: UILabel!
    
    @IBOutlet var productImageViewWidth: NSLayoutConstraint!
    
    @IBOutlet var sendReviewButton: UIButton!
    
    var boughtDelegate: BoughtCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        productImageViewWidth.constant = UIScreen.main.bounds.height * 10 / 100
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func tapSendButton(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        boughtDelegate?.tapSendButton(index: button.tag, title: button.titleLabel?.text ?? "")
        
    }
    
    @IBAction func tapBoughtAddButton(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        boughtDelegate?.tapBoughtAddButton(index: button.tag)
        
    }
    
}
