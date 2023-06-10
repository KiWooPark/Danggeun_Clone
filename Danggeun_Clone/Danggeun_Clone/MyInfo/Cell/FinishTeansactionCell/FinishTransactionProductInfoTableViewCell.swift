//
//  FinishTransactionProductInfoTableViewCell.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/08/16.
//

import UIKit

class FinishTransactionProductInfoTableViewCell: UITableViewCell {

    @IBOutlet var finishLabel: UILabel!
    @IBOutlet var productTitleLabel: UILabel!
    @IBOutlet var productPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
