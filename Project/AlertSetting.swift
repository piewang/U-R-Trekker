//
//  AlertSetting.swift
//  FirebaseTutorial
//
//  Created by Willy on 2017/9/11.
//  Copyright © 2017年 AppCoda. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import MapKit

class AlertSetting: UIViewController {
    
    func setting(target:UIViewController,title:String,message:String?,BTNtitle:String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: BTNtitle, style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        
        target.present(alertController, animated: true, completion: nil)
    }
    
    func settingWithAct(target:UIViewController,title:String,message:String?,BTNtitle:String,user:User){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: BTNtitle, style: .default) { _ in
            user.sendEmailVerification(completion: nil)
        }
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        target.present(alertController, animated: true, completion: nil)
    }
    
    func settingWithAct2(target:UIViewController,title:String,message:String?,BTNtitle:String){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: BTNtitle, style: .default) { _ in
       
            guard let vc = target.storyboard?.instantiateViewController(withIdentifier: "LogInViewController") else {
                return
            }
            target.present(vc, animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        
        target.present(alertController, animated: true, completion: nil)
    }
    
}

