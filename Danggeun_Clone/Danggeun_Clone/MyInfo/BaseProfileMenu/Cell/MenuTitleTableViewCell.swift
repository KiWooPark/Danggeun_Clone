//
//  MenuTitleTableViewCell.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/02/10.
//

import UIKit

// MARK: [Class or Struct] ----------
class MenuTitleTableViewCell: UITableViewCell {

    // MARK: [@IBOutlet] ----------
    @IBOutlet var menuTitleLabel: UILabel!
    @IBOutlet var underlineView: UIView!
    
    // MARK: [Override] ----------
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
