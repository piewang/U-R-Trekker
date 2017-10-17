//
//  Color.swift
//  HelloRecorder
//
//  Created by Willy on 2017/8/24.
//  Copyright © 2017年 Willy. All rights reserved.
//

import UIKit

class Color: NSObject {
    
    func colorSetting(target:UIView){
        
        let color4 = UIColor(red: 0.24, green: 0.73, blue: 0.56, alpha: 1)
        let color3 = UIColor(red: 0.27, green: 0.86, blue: 0.65, alpha: 1)
        let color1 = UIColor(red: 0.29, green: 0.92, blue: 0.70, alpha: 1)
        
        let gradient = CAGradientLayer()
        gradient.frame = target.frame
        gradient.colors = [color1.cgColor,color3.cgColor,color4.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 1)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        
        target.layer.insertSublayer(gradient, at: 0)
    }
    
    func colorSetting2(target:UIView){
        
        let color1 = UIColor(red: 0.08, green: 0.81, blue: 0.62, alpha: 0.8)
        let color3 = UIColor(red: 0.67, green: 0.93, blue: 0.65, alpha: 0.7)
        let color4 = UIColor(red: 0.86, green: 0.98, blue: 0.72, alpha: 0.6)
        
        let gradient = CAGradientLayer()
        gradient.frame = target.frame
        gradient.colors = [color1.cgColor,color3.cgColor,color4.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 1)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        
        target.layer.insertSublayer(gradient, at: 0)
    }
    
}
