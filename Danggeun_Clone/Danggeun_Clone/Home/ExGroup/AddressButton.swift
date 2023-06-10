//
//  AddressButton.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/02/06.
//

import UIKit

class AddressButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        setImage(UIImage(named: "locationIcon"), for: .normal)
        setTitleColor(.black, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        semanticContentAttribute = .forceRightToLeft
    }
}
