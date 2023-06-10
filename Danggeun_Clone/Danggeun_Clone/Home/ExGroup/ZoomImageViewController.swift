//
//  ZoomImageViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/06/08.
//

import UIKit
import SnapKit

class ZoomImageViewController: UIViewController {
    
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var zoomImageCollectionView: UICollectionView!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var zoomImagePageController: UIPageControl!
    
    var photoUrls = [String]()
    var photoIndex = 0
    var isFinish = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        zoomImageCollectionView.backgroundColor = UIColor.clear.withAlphaComponent(0)
        
        
        zoomImageCollectionView.reloadData()
        
        zoomImageCollectionView.layoutIfNeeded()
        
        zoomImageCollectionView.scrollToItem(at: IndexPath(row: photoIndex, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.closeButton.transform = CGAffineTransform(translationX: 0, y: -100)
        self.zoomImagePageController.transform = CGAffineTransform(translationX: 0, y: 100)
        
        UIView.animate(withDuration: 0.5, delay: 0)  {
            self.backgroundView.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.5) {
                self.closeButton.transform = .identity
                self.zoomImagePageController.transform = .identity
            }
        }
    }
    
    @IBAction func tapCloseButton(_ sender: Any) {
        
        UIView.animate(withDuration: 0.5, delay: 0) {
            self.closeButton.transform = CGAffineTransform(translationX: 0, y: -100)
            self.zoomImagePageController.transform = CGAffineTransform(translationX: 0, y: 100)
            self.backgroundView.alpha = 0
            self.zoomImageCollectionView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }
}

extension ZoomImageViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ZoomProductImageCollectionViewCell else { return UICollectionViewCell() }
        cell.tag = indexPath.row
        
//        if indexPath.row == photoIndex {
//            cell.setup(url: photoUrls[indexPath.row], height: zoomImageCollectionView.frame.height / 2, isAnimate: true)
//        } else {
//            cell.setup(url: photoUrls[indexPath.row], height: zoomImageCollectionView.frame.height / 2, isAnimate: false)
//        }
        return cell
    }
}

extension ZoomImageViewController: UICollectionViewDelegate {
   
}

extension ZoomImageViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: collectionView.frame.height)
    }
}

extension ZoomImageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.tag == 100 {
            
            if !isFinish {
                if scrollView.contentOffset.y > 0 {
                    let scale = (scrollView.contentOffset.y - 1) / scrollView.frame.height
                    backgroundView.alpha = 1 - scale
                    
                    if (scrollView.contentOffset.y - 1) > 150 {
                        isFinish = true
                        
                        UIView.animate(withDuration: 0.5) {
                            self.backgroundView.alpha = 0
                            self.zoomImageCollectionView.alpha = 0
                            self.zoomImageCollectionView.transform = CGAffineTransform(translationX: 0, y: -1000)
                        } completion: { _ in
                            self.dismiss(animated: false)
                        }
                    }
                    
                    if (scrollView.contentOffset.y - 1) != 0 {
                        UIView.animate(withDuration: 0.5) {
                            self.closeButton.transform = CGAffineTransform(translationX: 0, y: -100)
                            self.zoomImagePageController.transform = CGAffineTransform(translationX: 0, y: 100)
                        }
                    } else {
                        UIView.animate(withDuration: 0.5) {
                            self.closeButton.transform = .identity
                            self.zoomImagePageController.transform = .identity
                        }
                    }
                    
                } else {
                    let scale = scrollView.contentOffset.y / scrollView.frame.height
                    backgroundView.alpha = 1 - -scale
                    
                    if (scrollView.contentOffset.y) < -150 {
                        isFinish = true
                        
                        UIView.animate(withDuration: 0.5) {
                            self.backgroundView.alpha = 0
                            self.zoomImageCollectionView.alpha = 0
                            self.zoomImageCollectionView.transform = CGAffineTransform(translationX: 0, y: 1000)
                        } completion: { _ in
                            self.dismiss(animated: false)
                        }
                    }
                    
                    if (scrollView.contentOffset.y) != 0 {
                        UIView.animate(withDuration: 0.5) {
                            self.closeButton.transform = CGAffineTransform(translationX: 0, y: -100)
                            self.zoomImagePageController.transform = CGAffineTransform(translationX: 0, y: 100)
                        }
                    } else {
                        UIView.animate(withDuration: 0.5) {
                            self.closeButton.transform = .identity
                            self.zoomImagePageController.transform = .identity
                        }
                    }
                }
            }
        }
    }
}

