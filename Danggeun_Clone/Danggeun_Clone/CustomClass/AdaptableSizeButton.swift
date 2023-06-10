//
//  AdaptableSizeButton.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/02/28.
//

import Foundation
import UIKit

// MARK: [Class or Struct] ----------
class AdaptableSizeButton: UIButton {
    override var intrinsicContentSize: CGSize {
        let labelSize = titleLabel?.sizeThatFits(CGSize(width: frame.size.width, height: CGFloat.greatestFiniteMagnitude)) ?? .zero
        let desiredButtonSize = CGSize(width: labelSize.width + titleEdgeInsets.left + titleEdgeInsets.right, height: labelSize.height + titleEdgeInsets.top + titleEdgeInsets.bottom)
        
        return desiredButtonSize
    }
}
