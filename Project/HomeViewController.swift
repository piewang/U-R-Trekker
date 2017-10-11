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
    
    @IBOutlet weak var fakeView: UIView!
    @IBOutlet weak var logInLabel: UILabel!
    @IBOutlet weak var logInActiveView: UIActivityIndicatorView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var googleLogIn: GIDSignInButton!
    
    let alert = AlertSetting()

    let fbReadPermission = ["public_profile", "email", "user_friends"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        fakeView.isHidden = true
        logInLabel.isHidden = true
        logInActiveView.isHidden = true
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - FB login
    @IBAction func fbLogIn(_ sender: Any) {
        //登入fb
        FBSDKLoginManager().logIn(withReadPermissions: fbReadPermission, from: self) { [weak self](result, error) in
            
            if error != nil{
                
                self?.alert.setting(target: self!, title: "Error", message: error?.localizedDescription, BTNtitle: "OK")
                
                print(error!)
                
                return
                
            } else {
                //打開登入中的頁面顯示
                self?.fakeView.isHidden = false
                self?.logInActiveView.startAnimating()
                self?.logInLabel.isHidden = false
                
                //確定登入fb後，用戶資料再用來登入firebase
                firebaseWorks.signInFireBaseWithFB(completion: {
                    [weak self](success) in
                    
                    if success == Result.success {

                        let storyboard = UIStoryboard(name: "Work", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
                
                        self?.logInActiveView.stopAnimating()
                        self?.logInLabel.isHidden = true
//                        DispatchQueue.main.async {
                            self?.fakeView.isHidden = true
//                        }
                        self?.present(vc, animated: true, completion: nil)
                        
                        
                    }
                })
            }
        }
    }
    //MARK: - google login
    @IBAction func googleLogIn(_ sender: Any) {
        
        GIDSignIn.sharedInstance().signIn()
        
    }
    //登入google
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
            print(error.localizedDescription)
            return
        }
        //打開登入中的頁面顯示
        self.fakeView.isHidden = false
        self.logInActiveView.startAnimating()
        self.logInLabel.isHidden = false
        
        //確定登入google後，用戶資料再用來登入firebase
        firebaseWorks.signInFireBaseWithGoogle(user: user) { [weak self](result) in
            
            if result == Result.success{
                let storyboard = UIStoryboard(name: "Work", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
                
                self?.logInActiveView.stopAnimating()
                self?.logInLabel.isHidden = true
                DispatchQueue.main.async {
                    self?.fakeView.isHidden = true
                }
                self?.present(vc, animated: true, completion: nil)
                
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
