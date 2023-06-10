//
//  ProductIndicatorTableViewCell.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/12/01.
//

import UIKit

class ProductIndicatorTableViewCell: UITableViewCell {

    @IBOutlet var indicatorView: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
