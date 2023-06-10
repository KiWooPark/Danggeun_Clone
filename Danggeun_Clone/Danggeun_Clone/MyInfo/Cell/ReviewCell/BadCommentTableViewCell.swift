//
//  BadCommentTableViewCell.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/08/18.
//

import UIKit

protocol CommentDelegate {
    func sendPreference(comment: String?)
    func selectComment(buttons: [Int:Bool])
}

class BadCommentTableViewCell: UITableViewCell {

    @IBOutlet var commentButton: [UIButton]!
    
    var commentButtonState = [Int:Bool]()
    var badDelegate: CommentDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func tapCommentButton(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        
        button.isSelected.toggle()
    
        commentButtonState.removeAll()
        
        for index in commentButton.indices {
            commentButtonState[commentButton[index].tag] = commentButton[index].isSelected
        }
        
        badDelegate?.selectComment(buttons: commentButtonState)
    }
    
    @IBAction func tapSendPreferenceButton(_ sender: Any) {
        
        badDelegate?.sendPreference(comment: nil)
        
    }
}
