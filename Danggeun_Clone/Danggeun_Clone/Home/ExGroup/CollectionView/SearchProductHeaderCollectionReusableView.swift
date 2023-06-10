//
//  SearchProductHeaderCollectionReusableView.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/10/13.
//

import UIKit

protocol SearchProductHeaderCollectionReusableViewDelegate {
    func deleteAllWords()
}

class SearchProductHeaderCollectionReusableView: UICollectionReusableView {
        
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var deleteAllWordsButton: UIButton!
    
    var delegate: SearchProductHeaderCollectionReusableViewDelegate?
    
    @IBAction func tapDeleteAllWordsButton(_ sender: Any) {
        delegate?.deleteAllWords()
    }
}
