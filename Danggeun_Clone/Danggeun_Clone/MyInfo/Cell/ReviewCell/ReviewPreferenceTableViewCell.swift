//
//  ReviewPreferenceTableViewCell.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/08/18.
//

import UIKit

protocol ReviewDelegate {
    func changeCommentState(tag: Int)
}

class ReviewPreferenceTableViewCell: UITableViewCell {
    
    @IBOutlet var myNicknameLabel: UILabel!
    @IBOutlet var anotherUserNicknameLabel: UILabel!
    
    @IBOutlet var badImageView: UIImageView!
    @IBOutlet var generalImageView: UIImageView!
    @IBOutlet var goodImageView: UIImageView!
    
    @IBOutlet var badButton: UIButton!
    @IBOutlet var generalButton: UIButton!
    @IBOutlet var goodButton: UIButton!
    
    var reviewDelegate: ReviewDelegate?
    
    @IBOutlet var badCommentImageViewHeightConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

        badCommentImageViewHeightConstraint.constant = UIScreen.main.bounds.width * 20 / 100
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func tapBadButton(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        
        reviewDelegate?.changeCommentState(tag: button.tag)
    }
    
    @IBAction func tapGeneralButton(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        reviewDelegate?.changeCommentState(tag: button.tag)
    }
    
    @IBAction func tapGoodButton(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        reviewDelegate?.changeCommentState(tag: button.tag)
    }
}
