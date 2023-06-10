//
//  ZoomProductImagesViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/02/23.
//

import UIKit

// MARK: [Class or Struct] ----------
class ZoomProductImagesViewController: UIViewController {

    // MARK: [@IBOutlet] ----------
    @IBOutlet var zoomImageViewCollectionView: UICollectionView!
    @IBOutlet var imagePageController: UIPageControl!
    @IBOutlet var closeButton: UIButton!
    
    // MARK: [Let Or Var] ----------
    var productHeights = [CGFloat]()
    var productImages = [UIImage]()
    var imageIndex = 0
    
    // MARK: [Override] ----------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configPageControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        zoomImageViewCollectionView.layoutIfNeeded()
        zoomImageViewCollectionView.scrollToItem(at: IndexPath(row: imageIndex, section: 0), at: .centeredHorizontally, animated: false)
    }
   
    // MARK: [@IBAction] ----------
    @IBAction func tapCloseButton(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    // MARK: [Function] ----------
    func configPageControl() {
        imagePageController.currentPage = imageIndex
        imagePageController.numberOfPages = productImages.count
        imagePageController.pageIndicatorTintColor = .lightGray
        imagePageController.currentPageIndicatorTintColor = .white
    }
}

// MARK: [CollectionView - DataSource] ----------
extension ZoomProductImagesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "zoomProductImageCell", for: indexPath) as? ZoomProductImageCollectionViewCell else { return UICollectionViewCell() }
        
        if indexPath.row == imageIndex {
            cell.setup(image: productImages[indexPath.row], height: self.view.frame.height / 2, isAnimate: true)
        } else {
            cell.setup(image: productImages[indexPath.row], height: self.view.frame.height / 2, isAnimate: false)
        }
        return cell
    }
}

// MARK: [CollectionView - DelegateFlowLayout] ----------
extension ZoomProductImagesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: collectionView.frame.height)
    }
}

// MARK: [ScrollView - Delegate] ----------
extension ZoomProductImagesViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
        switch scrollView.tag {
        case 100:
            if scrollView.contentOffset.y > 0 {
                let scale = scrollView.contentOffset.y / self.view.frame.height
                self.view.backgroundColor = .black.withAlphaComponent(1 - scale)
      
                if scrollView.contentOffset.y > 150 {
                    UIView.animate(withDuration: 0.5) {
                        self.zoomImageViewCollectionView.transform = CGAffineTransform(translationX: 0, y: -1000)
                        self.view.alpha = 0
                        self.closeButton.alpha = 0
                        self.imagePageController.alpha = 0
                    } completion: { _ in
                        Thread.sleep(forTimeInterval: 0.5)
                        self.dismiss(animated: false)
                    }
                }
            } else {
                let scale = -scrollView.contentOffset.y / self.view.frame.height
                self.view.backgroundColor = .black.withAlphaComponent(1 - scale)
                
                if scrollView.contentOffset.y < -150 {
                    UIView.animate(withDuration: 0.5) {
                        self.zoomImageViewCollectionView.transform = CGAffineTransform(translationX: 0, y: 1000)
                        self.view.alpha = 0
                        self.closeButton.alpha = 0
                        self.imagePageController.alpha = 0
                    } completion: { _ in
                        Thread.sleep(forTimeInterval: 0.5)
                        self.dismiss(animated: false)
                    }
                }
            }
        default:
            print("default")
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        imageIndex = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        imagePageController.currentPage = imageIndex
    }
}
