//
//  ZoomProductImageCollectionViewCell.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/12/06.
//

import UIKit

// MARK: [Class or Struct] ----------
class ZoomProductImageCollectionViewCell: UICollectionViewCell {
    
    // MARK: [@IBOutlet] ----------
    @IBOutlet var productImageView: UIImageView!
    
    // MARK: [Let Or Var] ----------
    var isFirst = true

    // MARK: [Function] ----------
    func setup(image: UIImage, height: CGFloat, isAnimate: Bool) {

        let resizeImage = image.resizeImage(newWidth: UIScreen.main.bounds.width)
        
        print(image, resizeImage)

        let scale = height / (resizeImage.size.height)
        let translationY = -(scale * (resizeImage.size.height)) / 2
        
        if isAnimate && isFirst {
            isFirst = false
            
            productImageView.image = resizeImage
            productImageView.transform = CGAffineTransform(translationX: 0, y: translationY).scaledBy(x: 1, y: scale)
            
            UIView.animate(withDuration: 0.5) {
                self.productImageView.transform = .identity
            }
        } else {
            self.productImageView.image = resizeImage
        }
    }
}


//    @IBOutlet var productImageView: UIImageView!
//    var isFirst = true
//
//    func setup(url: String, height: CGFloat, isAnimate: Bool) {
//        FirebaseManager.shared.downloadImage(url: url) { result in
//            let resizeImage = result?.resizeImage(newWidth: UIScreen.main.bounds.width)
//
//            // collectionView 절반 크기로 변환된 높이
//            // 변환된 높이의 절반씩 위아래 여백이 생김
//            // 해당 여백만큼 translationY 시작위치 계산
//            let scale = height / (resizeImage?.size.height ?? 0.0)
//            let translationY = -(scale * (resizeImage?.size.height ?? 0.0)) / 2
//
//            DispatchQueue.main.async {
//                if isAnimate && self.isFirst {
//                    self.isFirst = false
//                    self.productImageView.transform = CGAffineTransform(translationX: 0, y: translationY).scaledBy(x: 1, y: scale)
//
//                    // 이미지뷰 크기 변경하고 이미지 넣어야함
//                    self.productImageView.image = resizeImage
//                    UIView.animate(withDuration: 0.5) {
//                        self.productImageView.transform = .identity
//                        self.productImageView.layoutIfNeeded()
//                    }
//                } else {
//                    self.productImageView.image = resizeImage
//                }
//            }
//        }
//    }

