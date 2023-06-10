//
//  PhotosCollectionViewCell.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/05/17.
//

import UIKit

protocol PhotosCollectionViewDelegate {
    func deletePhoto(index: Int)
}

class PhotosCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var selectedImageView: UIImageView!
    @IBOutlet var representativeLabel: UILabel!
    
    var delegate: PhotosCollectionViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectedImageView.layer.cornerRadius = 5
    
        representativeLabel.clipsToBounds = true
        representativeLabel.layer.cornerRadius = 5
        representativeLabel.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMaxYCorner, .layerMaxXMaxYCorner)
    }
    
    @IBAction func tapDeleteButton(_ sender: Any) {
        delegate?.deletePhoto(index: deleteButton.tag)
    }
}
