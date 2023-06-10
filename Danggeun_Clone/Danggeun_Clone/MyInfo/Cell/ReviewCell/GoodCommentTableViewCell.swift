//
//  GoodCommentTableViewCell.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/08/18.
//

import UIKit

class GoodCommentTableViewCell: UITableViewCell {

    @IBOutlet var commentButton: [UIButton]!
    @IBOutlet var commentTextView: UITextView!
    
    var commentButtonState = [Int:Bool]()
    var goodDelegate: CommentDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func tapGoodCommentButton(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        button.isSelected.toggle()
        
        for index in commentButton.indices {
            commentButtonState[commentButton[index].tag] = commentButton[index].isSelected
        }

        goodDelegate?.selectComment(buttons: commentButtonState)
        
    }
    
    @IBAction func tapSendPreferenceButton(_ sender: Any) {
        guard let text = commentTextView.text else { return }
        goodDelegate?.sendPreference(comment: text)
    }
}
