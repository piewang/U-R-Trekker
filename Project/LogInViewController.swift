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
    
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var action: UIActivityIndicatorView!
    @IBOutlet weak var fakeView: UIView!
    
    let alert = AlertSetting()
    let fireBase = FirebaseWorks()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        self.view.addGestureRecognizer(tapGesture)
        
        //設定登入中的頁面
        fakeView.isHidden = true
        action.isHidden = true
        displayLabel.isHidden = true
    }
    
    @objc func tap() {
        self.view.endEditing(true)
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
            
            Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { [weak self](user, error) in
                
                if error == nil {
                    if let user = Auth.auth().currentUser {
                        //是否通過email驗證
                        if user.isEmailVerified {
                            
                            self?.fakeView.isHidden = false
                            self?.action.startAnimating()
                            self?.displayLabel.isHidden = false
                            
                            //Go to the HomeViewController if the login is sucessful
                            let storyboard = UIStoryboard(name: "Work", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
                            
                            //用usersDataManager呼叫Login來登入coredata
                            usersDataManager.Login(email: (self?.emailTextField.text)!)
                            
                            self?.present(vc, animated: true, completion: nil)
                            
                        }else {
                            self?.alert.settingWithAct(target: self!, title: "Error", message: "抱歉，您帳號沒通過認證，如需重寄驗證信，請按OK", BTNtitle: "OK", user: user)
                        }
                    }
                } else {
                    // 提示用戶從 firebase 返回了一個錯誤。
                    self?.alert.setting(target: self!, title: "Error", message: error?.localizedDescription, BTNtitle: "OK")
                }
            }
        }
    }
}
