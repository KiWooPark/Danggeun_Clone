//
//  ResultReviewViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/09/05.
//

import UIKit
import FirebaseFirestore

class SendReviewViewController: UIViewController {

    @IBOutlet var otherUserLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var commentTextLabel: UILabel!
    
    @IBOutlet var commentLable1: UILabel!
    @IBOutlet var commentLable2: UILabel!
    @IBOutlet var commentLable3: UILabel!
    @IBOutlet var commentLable4: UILabel!
    
    @IBOutlet var getReviewButton: UIButton!
    
    var productData: ProductRegistrationModel?
    var vcType: String?
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "내가 보낸 거래 후기"
        
        getReviewButton.isHidden = vcType == "sela" ? true : false
        
        commentTextLabel.isHidden = true
        commentLable1.isHidden = true
        commentLable2.isHidden = true
        commentLable3.isHidden = true
        commentLable4.isHidden = true
       
        db.collection("유저정보").document(productData?.buyer ?? "" ).collection("매너평가").document("\(productData?.productId ?? "")-\(productData?.phoneNumber ?? "")").getDocument { snapShot, error in
            if let error = error {
                print("매너정보 가져오기 실패",error)
            }
            
            guard let document = snapShot?.data() else { return }
            
            DispatchQueue.main.async {
                for key in document.keys {
                    switch key {
                    case "5":
                        self.commentLable1.text = "• \(document["5"] as? String ?? "")"
                        self.commentLable1.isHidden = false
                    case "6":
                        self.commentLable2.text = "• \(document["6"] as? String ?? "")"
                        self.commentLable2.isHidden = false
                    case "7":
                        self.commentLable3.text = "• \(document["7"] as? String ?? "")"
                        self.commentLable3.isHidden = false
                    case "8":
                        self.commentLable4.text = "• \(document["8"] as? String ?? "")"
                        self.commentLable4.isHidden = false
                    case "9":
                        self.commentTextLabel.text = document["9"] as? String ?? ""
                        self.commentTextLabel.isHidden = false
                    default:
                        print("")
                    }
                }
            }
            
            self.db.collection("유저정보").document(self.productData?.buyer ?? "").getDocument { snapShot, error in
                if let error = error {
                    print("구매자 정보 가져오기 실패", error)
                }
                
                guard let nickname = snapShot?.data()?["nickname"] as? String else { return }
                
                DispatchQueue.main.async {
                    self.otherUserLabel.text = "\(nickname)님에게"
                    self.titleLabel.text = "\(nickname)과 \(self.productData?.title ?? "")를 거래했어요."
                }
            }
        }
    }
    
    @IBAction func tapResultReviewButton(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "getReviewVC") as? GetReviewViewController else { return }
        vc.modalPresentationStyle = .fullScreen
        vc.productId = productData?.productId ?? ""
        vc.seller = productData?.phoneNumber ?? ""
        vc.buyer = productData?.buyer ?? ""
        vc.productTitle = productData?.title ?? ""
        self.present(vc, animated: true)
    }
}
