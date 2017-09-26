//
//  LoginViewController.swift
//  FirebaseTutorial
//
//  Created by James Dacombe on 16/11/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LogInViewController: UIViewController {
    //Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let alert = AlertSetting()
    let fireBase = FirebaseWorks()
    
    override func viewDidLoad() {
        usersDataManager = UsersManager.shared
    }
    
    @IBAction func goToSignInPage(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func goToRestPage(_ sender: Any) {
        
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResetPasswordViewController") else {
            return
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    //Login Action
    @IBAction func loginAction(_ sender: AnyObject) {
        if self.emailTextField.text == "" || self.passwordTextField.text == "" {
            // 提示用戶是不是忘記輸入 textfield ？
            alert.setting(target: self, title: "Error", message: "Please enter an email and password.", BTNtitle: "OK")
            
        } else {
            
            Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (user, error) in
                
                if error == nil {
                    if let user = Auth.auth().currentUser {
                        
                        if user.isEmailVerified {
                            print ("Email verified. Signing in...")
                            //Go to the HomeViewController if the login is sucessful
                            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") else {
                                return
                            }
                            //用firebase物件呼叫Login來登入coredata
                            self.fireBase.Login(email: self.emailTextField.text!)
                            
                            self.present(vc, animated: true, completion: nil)
                            
                        }else {
                            self.alert.settingWithAct(target: self, title: "Error", message: "抱歉，您帳號沒通過認證，如需重寄驗證信，請按OK", BTNtitle: "OK", user: user)
                        }
                    }
                } else {
                    // 提示用戶從 firebase 返回了一個錯誤。
                    self.alert.setting(target: self, title: "Error", message: error?.localizedDescription, BTNtitle: "OK")
                }
            }
        }
    }
}
