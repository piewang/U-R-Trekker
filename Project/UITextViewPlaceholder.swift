//
//  UITextViewPlaceholder.swift
//  Project
//
//  Created by pie wang on 2017/10/6.
//  Copyright © 2017年 Willy. All rights reserved.
//

import Foundation
import UIKit

// Extend UITextView and implemented UITextViewDelegate to listen for changes
extension UITextView: UITextViewDelegate {
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    // The UITextView placeholder text
    public var placeholder: String? {
        get {
            var placeholderText:String?
            
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            }
            return placeholderText
        }
        
        set {
            if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            } else {
                self.addplaceholder(newValue!)
            }
        }
    }
    
    // Adds a placeholder UILabel to this UITextView
    private func addplaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()
        
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        
//        placeholderLabel.font = self.font
        placeholderLabel.font = UIFont(name: placeholderLabel.font.fontName, size: 20)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.tag = 100
        
        placeholderLabel.isHidden = self.text.characters.count > 0
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
        self.delegate = self
    }
    
    // Resize the placeholder when the UITextView bounds change
    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
            let labelX = self.textContainer.lineFragmentPadding
            let labelY = self.textContainerInset.top - 2
            let labelWidth = self.frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height
            
            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }

    public func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = self.text.characters.count > 0
        }
    }
    

    
    


}
