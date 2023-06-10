//
//  PhotoPopupViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/10/25.
//

import UIKit

// MARK: [Class or Struct] ----------
class PhotoPopupViewController: UIViewController {

    // MARK: [@IBOutlet] ----------
    @IBOutlet var visualView: UIView!
    @IBOutlet var popupView: UIView!
    
    @IBOutlet var popupLabel: UILabel!
    @IBOutlet var closeButton: UIButton!
    
    // MARK: [Let Or Var] ----------
    var photoCount: Int?
    
    // MARK: [Override] ----------
    override func viewDidLoad() {
        super.viewDidLoad()

        popupView.layer.cornerRadius = 10
        closeButton.layer.cornerRadius = 10
        
        if let photoCount = photoCount {
            popupLabel.text = "이미지는 최대 \(photoCount)장까지 첨부할 수 있어요."
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.3, delay: 0.0) {
            self.visualView.alpha = 0.5
            self.popupView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }
    }
    
    // MARK: [@IBAction] ----------
    @IBAction func tapCloseButton(_ sender: Any) {
        dismiss(animated: false)
    }
}
