//
//  ContentTableViewCell.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/02/02.
//

import UIKit

// MARK: [Protocol] ----------
protocol ContentTableViewCellDelegate: AnyObject {
    func updateTextViewHeight(cell: ContentTableViewCell, textView: UITextView)
}

// MARK: [Class or Struct] ----------
class ContentTableViewCell: UITableViewCell {

    // MARK: [@IBOutlet] ----------
    @IBOutlet var contentTextView: UITextView!
    @IBOutlet var placeholderLabel: UILabel!
    
    // MARK: [Let Or Var] ----------
    weak var delegate: ContentTableViewCellDelegate?
    
    let loginUserData = UserModel.getUserData()
    let placeholderText = ""
    
    // MARK: [Override] ----------
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configTextView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("layoutSubviews 111 ")
    }

    // MARK: [Function] ----------
    func configTextView() {
        contentTextView.delegate = self
        contentTextView.isScrollEnabled = false
        contentTextView.sizeToFit()
        contentTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        contentTextView.textContainer.lineFragmentPadding = 0
        
        placeholderLabel.text = "\(loginUserData?.selectedAddress.components(separatedBy: " ").last ?? "")에 올릴 게시글 내용을 작성해주세요. (판매 금지 물품은 게시가 제한될 수 있어요.)\n\n\n\n\n"
        placeholderLabel.textColor = .placeholderText
    }
}

// MARK: [TextView - Delegate] ----------
extension ContentTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        delegate?.updateTextViewHeight(cell: self, textView: textView)
        
        placeholderLabel.isHidden = textView.text == "" ? false : true
    }
}
