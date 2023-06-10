//
//  ReviewProductInfoTableViewCell.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/08/18.
//

import UIKit

class ReviewProductInfoTableViewCell: UITableViewCell {
    
    @IBOutlet var productTitleLabel: UILabel!
    
    @IBOutlet var nicknameLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func tapUserChangeButton(_ sender: Any) {
        
        
    }
    

}
