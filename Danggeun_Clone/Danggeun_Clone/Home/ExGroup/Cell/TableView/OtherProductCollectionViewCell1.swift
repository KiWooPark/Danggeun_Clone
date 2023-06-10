//
//  OtherProductCollectionViewCell.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/05/30.
//

import UIKit
import SnapKit

class OtherProductCollectionViewCell1: UICollectionViewCell {
    
    static let identifier = "productImageCollectionCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(productTitleLabel)
        stackView.addArrangedSubview(priceLabel)
        contentView.addSubview(stackView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        stackView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.height.equalTo(stackView.snp.height).multipliedBy(0.7)
        }
    }
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalCentering
        stackView.spacing = 10
        stackView.backgroundColor = .white
        return stackView
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let productTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "제목"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.text = "가격"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
}
