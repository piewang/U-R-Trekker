//
//  SignUpViewController.swift
//  FirebaseTutorial
//
//  Created by James Dacombe on 16/11/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignInViewController: UIViewController {
    
    //Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordTextField2: UITextField!
    
    let alert = AlertSetting()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        self.view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func tap() {
        self.view.endEditing(true)
    }
    
    @IBAction func goToLogInPage(_ sender: Any) {
        
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "LogInViewController") else {
            return
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func goToRestPage(_ sender: Any) {
        
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResetPasswordViewController") else {
            return
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    //MARK: - Sign Up Action for email
    //註冊帳號
    @IBAction func createAccountAction(_ sender: AnyObject) {
        if emailTextField.text == "" && passwordTextField.text == ""{
            
            alert.setting(target: self, title: "Error", message: "請輸入你的email與密碼", BTNtitle: "OK")
            
        } else {
        
            if passwordTextField.text == passwordTextField2.text {
                //註冊到firebase裡
                firebaseWorks.registerFirebaseByEmail(name: "", email: emailTextField.text!, password: passwordTextField.text!, alertTarget: self)
                
            }else {
                alert.setting(target: self, title: "Error", message: "密碼不一致，請重新輸入", BTNtitle: "OK")
            }
        }
    }
}

