//
//  ContainerViewController.swift
//  Project
//
//  Created by Willy on 2017/9/28.
//  Copyright © 2017年 Willy. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

class ContainerViewController: UIViewController {

    let backGround = Color()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backGround.colorSetting(target: self.view)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logOut(_ sender: Any) {
        
        FBSDKLoginManager().logOut()
        GIDSignIn.sharedInstance().signOut()
        
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
