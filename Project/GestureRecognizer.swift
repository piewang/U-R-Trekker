//
//  GestureRecognizer.swift
//  Project
//
//  Created by Willy on 2017/9/5.
//  Copyright © 2017年 Willy. All rights reserved.
//

import UIKit
import MapKit

class GestureRecognizer: UIViewController {
    
    func turnOnMenu(target: UIBarButtonItem,VCtarget:UIViewController) {
        
        if revealViewController() == nil {
            
            target.target = revealViewController()
            target.action = #selector(SWRevealViewController.revealToggle(_:))
        
            VCtarget.view.addGestureRecognizer(VCtarget.revealViewController().tapGestureRecognizer())
            
        }
        
    }
    
//    func turnOnMenuWithOther(target: UIBarButtonItem,VCtarget:UIViewController,viewTarget:MKMapView) {
//        
//        if revealViewController() == nil {
//            
//            target.target = revealViewController()
//            target.action = #selector(SWRevealViewController.revealToggle(_:))
//            
//            VCtarget..addGestureRecognizer(VCtarget.revealViewController().tapGestureRecognizer())
//            
//        }
//        
//    }
}
