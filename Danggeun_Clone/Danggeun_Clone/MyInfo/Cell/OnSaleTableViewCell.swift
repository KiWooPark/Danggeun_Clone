//
//  OnSaleTableViewCell.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/07/29.
//

import UIKit
import Kingfisher

protocol OnSaleCellDelegate {
    func tapReservationButton(index: Int)
    func tapFinishTransationButton(index: Int)
    func tapOnSaleAddButton(index: Int)
}

class OnSaleTableViewCell: UITableViewCell {
    
    @IBOutlet var productImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var reservationLabel: UILabel!
    
    @IBOutlet var reservationButton: UIButton!
    @IBOutlet var finishTransationButton: UIButton!
    @IBOutlet var addButton: UIButton!
    
    var delegate: OnSaleCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    @IBAction func tapReservationButton(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        delegate?.tapReservationButton(index: button.tag)
    }
    
    
    @IBAction func tapFinishTransationButton(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        delegate?.tapFinishTransationButton(index: button.tag)
    }
    
    @IBAction func tapAddButton(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        delegate?.tapOnSaleAddButton(index: button.tag)
    }
    
}
