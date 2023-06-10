//
//  FinishedTableViewCell.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/07/29.
//

import UIKit

protocol FinishedCellDelegate {
    func tapSendButton(index: Int, title: String)
    func tapFinishedAddButton(index: Int)
}

class FinishedTableViewCell: UITableViewCell {

    @IBOutlet var productImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var finishTransationLabel: UILabel!
    
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var addButton: UIButton!
    
    var delegate: FinishedCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func tapSendButton(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        delegate?.tapSendButton(index: button.tag, title: button.titleLabel?.text ?? "")
    }
    
    @IBAction func tapAddButton(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        delegate?.tapFinishedAddButton(index: button.tag)
    }
    
}
