//
//  CategoryLabelPadding.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/02/28.
//

import Foundation
import UIKit

// MARK: [Class or Struct] ----------
class CategoryLabelPadding: UILabel {
    
    // MARK: [Let Or Var] ----------
    @IBInspectable var topInset: CGFloat = 0
    @IBInspectable var bottomInset: CGFloat = 0
    @IBInspectable var leftInset: CGFloat = 1
    @IBInspectable var rightInset: CGFloat = 1
    
    // MARK: [Override] ----------
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset, height: size.height + topInset + bottomInset)
    }
}
