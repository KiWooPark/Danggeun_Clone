//
//  HideTableViewCell.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/07/29.
//

import UIKit

protocol HideCellDelegate {
    func tapRestoreHideButton(index: Int)
    func tapHideAddButton(index: Int)
}

class HideTableViewCell: UITableViewCell {

    @IBOutlet var productImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var finishTransationLabel: UILabel!
    
    @IBOutlet var restoreHideButton: UIButton!
    @IBOutlet var addButton: UIButton!
    
    var delegate: HideCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func tapRestoreHideButton(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        delegate?.tapRestoreHideButton(index: button.tag)
    }
    
    @IBAction func tapAddButton(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        delegate?.tapHideAddButton(index: button.tag)
    }
    
}
