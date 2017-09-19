//
//  mainViewController.swift
//  FirebaseTutorial
//
//  Created by Willy on 2017/9/11.
//  Copyright © 2017年 AppCoda. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn

class HomeViewController: UIViewController,GIDSignInUIDelegate,GIDSignInDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var googleLogIn: GIDSignInButton!
    
    let alert = AlertSetting()
    
    let fbReadPermission = ["public_profile", "email", "user_friends"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: FB login
    @IBAction func fbLogIn(_ sender: Any) {
        
        FBSDKLoginManager().logIn(withReadPermissions: fbReadPermission, from: self) { (result, error) in
            
            if error != nil{
                
                self.alert.setting(target: self, title: "Error", message: error?.localizedDescription, BTNtitle: "OK")
                
                print(error!)
                return
            }else{
                //確定登入fb後，用戶資料再用來登入firebase
                firebaseWorks.signInFireBaseWithFB(completion: {
                    (result) in
                    if result == Result.success{
                        
                        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") else {
                            return
                        }
                        self.present(vc, animated: true, completion: nil)
                    }
                })
            }
        }
    }
    // MARK: google login
    @IBAction func googleLogIn(_ sender: Any) {
        
        GIDSignIn.sharedInstance().signIn()
        
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
            print(error.localizedDescription)
            return
        }
        firebaseWorks.signInFireBaseWithGoogle(user: user) { (result) in
            
            if result == Result.success{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
                self.present(vc, animated: true, completion: nil)
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
