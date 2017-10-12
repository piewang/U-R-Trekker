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
    
    func pauseRecAlert(target: UIViewController) {
        
    }
    
    func runNameAlert(target: UIViewController) {
        let alert = UIAlertController(title: "記錄命名", message: "您可以為本次記錄新增名稱，或直接以記錄日期命名", preferredStyle: .alert)
        alert.addTextField { (tf) in
            tf.placeholder = String(describing: usersDataManager.runItem?.timestamp)
        }
        let ok = UIAlertAction(title: "確定", style: .default) { _ in
            if alert.textFields?.first?.text?.isEmpty == true {
                usersDataManager.runItem?.runname = String(describing: usersDataManager.runItem?.timestamp)
            } else {
                let runName = alert.textFields?.first?.text
                usersDataManager.runItem?.runname = runName
            }
        }
        alert.addAction(ok)
        target.present(alert, animated: true, completion: nil)
    }
    
    
}

