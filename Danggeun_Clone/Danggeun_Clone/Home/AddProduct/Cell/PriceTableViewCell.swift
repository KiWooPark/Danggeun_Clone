//
//  PriceTableViewCell.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/02/02.
//

import UIKit

// MARK: [Class or Struct] ----------
class PriceTableViewCell: UITableViewCell {
    
    // MARK: [@IBOutlet] ----------
    @IBOutlet var priceTextField: UITextField!
    
    // MARK: [Override] ----------
    override func awakeFromNib() {
        super.awakeFromNib()
        
        priceTextField.delegate = self
    }
}

// MARK: [TextField - Delegate] ----------
extension PriceTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // replacementString : 방금 입력된 문자 하나, 붙여넣기 시에는 붙여넣어진 문자열 전체
        // return -> 텍스트가 바뀌어야 한다면 true, 아니라면 false
        // 이 메소드 내에서 textField.text는 현재 입력된 string이 붙기 전의 string
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal // 1,000,000
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 0 // 허용하는 소숫점 자리수
        
        // formatter.groupingSeparator // .decimal -> ,
        
        if let removeAllSeprator = textField.text?.replacingOccurrences(of: formatter.groupingSeparator, with: "") {
            
            var beforeForemattedString = removeAllSeprator + string
            
            if formatter.number(from: string) != nil {
                if let formattedNumber = formatter.number(from: beforeForemattedString),
                    let formattedString = formatter.string(from: formattedNumber) {
        
                    
                    textField.text = formattedString
                    
                    if beforeForemattedString.count == 10 {
                        textField.text = "999,999,999"
                        return false
                    }
                    
                    return false
                }
            } else { // 숫자가 아닐 때
                if string == "" { // 백스페이스일때
                    let lastIndex = beforeForemattedString.index(beforeForemattedString.endIndex, offsetBy: -1)
                    beforeForemattedString = String(beforeForemattedString[..<lastIndex])
                    if let formattedNumber = formatter.number(from: beforeForemattedString), let formattedString = formatter.string(from: formattedNumber){
                        textField.text = formattedString
                        return false
                    }
                }else{ // 문자일 때
                    print("dulr")
                    return false
                }
            }
        }
        return true
    }
}

