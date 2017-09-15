//
//  ViewController+visualEffectView.swift
//  Project
//
//  Created by Willy on 2017/9/12.
//  Copyright © 2017年 Willy. All rights reserved.
//

import Foundation

extension HomeViewController {
    
    func createFrostBackground(img:String) {
        
        let x = self.view.frame.width
        let y = self.view.frame.height
    
        let newView = UIView(frame: CGRect(x: 0, y: 0, width: x, height: y))
        guard  let image = UIImage(named:img) else {
            return
        }
        newView.backgroundColor = UIColor(patternImage: image)
        
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        visualEffectView.frame = newView.frame
        
        newView.addSubview(visualEffectView)
        self.view.insertSubview(newView, at: 0)
    }
}
