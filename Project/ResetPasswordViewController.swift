//
//  ResetPasswordViewController.swift
//  FirebaseTutorial
//
//  Created by James Dacombe on 16/11/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ResetPasswordViewController: UIViewController {
    
    let alert = AlertSetting()
    // Outlets
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBAction func goToLogInPage(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goToSignInPage(_ sender: Any) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // Reset Password Action
    @IBAction func submitAction(_ sender: AnyObject){
        if self.emailTextField.text == "" {
            
            alert.setting(target: self, title: "Oops!", message: "Please enter an email.", BTNtitle: "OK")
            
        } else {
            Auth.auth().sendPasswordReset(withEmail: self.emailTextField.text!, completion: { (error) in
                
                var title = ""
                var message = ""
                
                if error != nil {
                    title = "Error!"
                    message = (error?.localizedDescription)!
                } else {
                    title = "Success!"
                    message = "Password reset email sent."
                    self.emailTextField.text = ""
                }
                self.alert.setting(target: self, title: title, message: message, BTNtitle: "OK")
            })
        }
    }
    
    
}
