//
//  UnderlineSegmentedControl.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/01/25.
//

import UIKit

// MARK: [Class or Struct] ----------
class UnderlineSegmentedControl: UISegmentedControl {
    
    // MARK: [Let Or Var] ----------
    private lazy var underlineView: UIView = {
        let width = UIScreen.main.bounds.width / CGFloat(self.numberOfSegments)
        let height = 3.0
        let xPosition = CGFloat(self.selectedSegmentIndex * Int(width))
        let yPosition = self.bounds.size.height - 3.0
        let frame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
        let view = UIView(frame: frame)
        view.restorationIdentifier = "underlineView"
        view.backgroundColor = .black
        return view
    }()

    private lazy var underlineView2: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray6
        return view
    }()

    // MARK: [Override] ----------
    override func awakeFromNib() {
        super.awakeFromNib()
        
        underlineView.frame.origin.x = 0
       
        removeBackgroundAndDivider()
        
        setTitleTextAttributes([.foregroundColor: UIColor.black, .font : UIFont.boldSystemFont(ofSize: 15)], for: .selected)
        setTitleTextAttributes([.foregroundColor: UIColor.gray, .font : UIFont.boldSystemFont(ofSize: 15)], for: .normal)
        
        self.addSubview(underlineView)
        self.addSubview(underlineView2)
        
        NSLayoutConstraint.activate([
            underlineView2.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            underlineView2.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            underlineView2.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            underlineView2.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        self.layer.cornerRadius = 0
        self.layer.masksToBounds = true
        self.bringSubviewToFront(underlineView)
    }
    
    // MARK: [Function] ----------
    private func removeBackgroundAndDivider() {
        let image = UIImage()
        self.setBackgroundImage(image, for: .normal, barMetrics: .default)
        self.setBackgroundImage(image, for: .selected, barMetrics: .default)
        self.setBackgroundImage(image, for: .highlighted, barMetrics: .default)
        
        self.setDividerImage(image, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
        
        self.underlineView.frame.origin.x = 0
        
    }
}
