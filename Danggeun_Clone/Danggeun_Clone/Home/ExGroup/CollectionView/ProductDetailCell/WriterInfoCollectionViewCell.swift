//
//  WriterInfoCollectionViewCell.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/12/04.
//

import UIKit

class WriterInfoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var nicknameLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var temperatureImageView: UIImageView!
    @IBOutlet var temperatureProgressBar: UIProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    
}
