//
//  TestView.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/12/15.
//

import UIKit

// MARK: [Class or Struct] ----------
class MyAddressButtonView: UIView {
    
    // MARK: [Let Or Var] ----------
    let addressButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "locationIcon"), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.semanticContentAttribute = .forceRightToLeft
        return button
    }()
    
    // MARK: [Override OR Init] ----------
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        configConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.layoutFittingExpandedSize.width, height: self.bounds.height)
    }

    // MARK: [Function] ----------
    func setup() {
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
        self.addSubview(addressButton)
    }
    
    func configConstraint() {
        NSLayoutConstraint.activate([
            addressButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            addressButton.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}

