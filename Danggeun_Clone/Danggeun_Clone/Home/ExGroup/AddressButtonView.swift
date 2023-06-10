//
//  AddressButtonView.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/02/06.
//

import Foundation
import UIKit

class AddressButtonView: UIView {
    
    let addressButton: AddressButton = {
        let button = AddressButton()
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.layoutFittingExpandedSize.width, height: self.bounds.height)
    }
    
    func setup() {

        addSubview(addressButton)
        
        NSLayoutConstraint.activate([
            addressButton.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 5),
            addressButton.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}
