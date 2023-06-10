//
//  PaddingLabel.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/11/06.
//

import Foundation
import UIKit

// MARK: [Class or Struct] ----------
class PaddingLabel: UILabel {
    
    // MARK: [Let Or Var] ----------
    @IBInspectable var topInset: CGFloat = 5.0
    @IBInspectable var bottomInset: CGFloat = 5.0
    @IBInspectable var leftInset: CGFloat = 5.0
    @IBInspectable var rightInset: CGFloat = 5.0
    
    // MARK: [Override] ----------
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset, height: size.height + topInset + bottomInset)
    }
    
//    override var bounds: CGRect {
//        didSet { preferredMaxLayoutWidth = bounds.width - (leftInset + rightInset)}
//    }
}




