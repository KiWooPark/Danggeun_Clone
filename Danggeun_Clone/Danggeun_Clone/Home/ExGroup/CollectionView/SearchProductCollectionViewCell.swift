//
//  SearchProductCollectionViewCell.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/10/14.
//

import UIKit

protocol SearchProductCollectionViewCellDelegate {
    func deleteSearchWord(index: Int)
}

class SearchProductCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var searchWordLabel: UILabel!
    @IBOutlet var deleteButton: UIButton!
    
    var delegate: SearchProductCollectionViewCellDelegate?
    
    @IBAction func tapDeleteButton(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        delegate?.deleteSearchWord(index: button.tag)
    }
}
