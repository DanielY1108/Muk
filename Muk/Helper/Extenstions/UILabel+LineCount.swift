//
//  UILabel+LineCount.swift
//  Muk
//
//  Created by JINSEOK on 2023/04/29.
//

import UIKit

extension UILabel {
    
    // https://stackoverflow.com/questions/28108745/how-to-find-actual-number-of-lines-of-uilabel
    var lineCount: Int {
        let text = (self.text ?? "") as NSString

        let maxSize = CGSize(width: frame.size.width,
                             height: CGFloat(MAXFLOAT))
        let textHeight = text.boundingRect(with: maxSize,
                                           options: .usesLineFragmentOrigin,
                                           attributes: [.font: font as Any],
                                           context: nil).height
        let lineHeight = font.lineHeight
        
        return Int(ceil(textHeight / lineHeight))
    }
}
