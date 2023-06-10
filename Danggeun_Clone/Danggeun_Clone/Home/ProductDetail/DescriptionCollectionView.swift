//
//  TestCollectionView.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/01/17.
//

import UIKit

// MARK: [Class or Struct] ----------
class DescriptionCollectionView: UICollectionView {
    
    // MARK: [Override] ----------
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}
