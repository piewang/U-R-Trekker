//
//  Keyboard.swift
//  Project
//
//  Created by pie wang on 2017/9/12.
//  Copyright © 2017年 Willy. All rights reserved.
//

import Foundation
import UIKit

struct Keyboard{
    var active = false
    var external = false
    var bottomInset: CGFloat = 0.0
    var endFrame = CGRect.zero
    var curve = UIViewAnimationCurve.linear
    var options = UIViewAnimationOptions.curveLinear
    var duration: Double = 0.0
    var name: String!
    
    init(notification: Notification) {
        name = notification.name.rawValue
        if let durationValue = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber {
            duration = durationValue.doubleValue
        }
        else {
            duration = 0
        }
        if let rawCurveValue = (notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber) {
            let rawCurve = rawCurveValue.intValue
            curve = UIViewAnimationCurve(rawValue: rawCurve) ?? .easeOut
            let curveInt = UInt(rawCurve << 16)
            options = UIViewAnimationOptions(rawValue: curveInt)
        }
        else {
            curve = .easeOut
            options = .curveEaseOut
        }
        
        endFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
    }
}
