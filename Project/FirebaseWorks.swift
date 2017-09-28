//
//  FirebaseWorks.swift
//  SignInExample
//
//  Created by JerryWang on 2017/2/22.
//  Copyright © 2017年 Jerrywang. All rights reserved.
//

import Foundation
import Firebase
import FBSDKLoginKit
import GoogleSignIn

let firebaseWorks = FirebaseWorks()

var usersDataManager:UsersManager!
var uuid:String? = nil
var userName:String? = nil
var mail:String? = nil
var photoUrl:String? = nil
var CDpassword:String? = nil

enum Result{
    case success
    case fail
}

class FirebaseWorks {
    
    let alert = AlertSetting()
    //MARK: - SignInFireBaseWithFB or Goole
    //產生Credentials後註冊到firebase ( 啟動firebaseSignInWithCredential() )
    func signInFireBaseWithFB(completion: @escaping (_ result: Result) -> ()){
        
        let fbAccessToken = FBSDKAccessToken.current()
        guard let fbAccessTokenString = fbAccessToken?.tokenString else {
            return
        }
        
        let fbCredentials = FacebookAuthProvider.credential(withAccessToken: fbAccessTokenString)
        
        firebaseSignInWithCredential(credential: fbCredentials, completion: completion)
    }
    //產生Credentials後註冊到firebase( 啟動firebaseSignInWithCredential() )
    func signInFireBaseWithGoogle(user: GIDGoogleUser,completion: @escaping (_ result: Result) -> ()){
        
        guard let authentication = user.authentication else {
            print(user.authentication)
            return
        }
        
        let googleCredential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        firebaseSignInWithCredential(credential: googleCredential, completion: completion)
        
    }
    //MARK: - FirebaseSignInWithCredential
    //註冊fb或google帳號到firebase
    func firebaseSignInWithCredential(credential: AuthCredential,completion: @escaping (_ result: Result) -> ()){
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            if error != nil {
                //登入失敗 請重新登入
                print("Something went wrong with our FB user: ", error ?? "")
                return
            }else{
                
                print("Successfully logged in with our user: ", user ?? "")
                
                guard let uid = user?.uid else {
                    return
                }
                
                guard let profileImageUrl = user?.photoURL?.absoluteString, let email = user?.email, let name = user?.displayName else{
                    return
                }
                //可自行選擇想要上傳的使用者資料
                let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl] as [String: Any]
                
                let ref = Database.database().reference()
                
                let usersReference = ref.child("users").child(uid)
                
                usersReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
                    if error != nil{
                        print(error!)
                        return
                    }
                    uuid = uid
                    mail = email
                    userName = name
                    photoUrl = profileImageUrl
                    
                    //先判斷是否已經有資料在coredata,在執行存到coreData或登入
                    usersDataManager.createOrLogin()
                        
                    completion(Result.success)
                })
            }
        })
    }
    //MARK: - RegisterFirebaseByEmail
    //註冊帳號到firebase
    func registerFirebaseByEmail(name: String, email: String, password: String,alertTarget:UIViewController){
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user: User?, error) in
            
            if error != nil{
                self.alert.setting(target: alertTarget, title: "Error", message: error?.localizedDescription, BTNtitle: "OK")
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            let values = ["name": name , "email": email, "profileImageUrl": "" ] as [String: Any]
            
            let ref = Database.database().reference()
            
            let usersReference = ref.child("users").child(uid)
            
            usersReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
                if error != nil{
                    print(error!)
                    return
                }
                
                mail = email
                CDpassword = password
                
                //因為Auth已經幫我們判斷好是否有相同帳號，所以這邊直接存擋
                usersDataManager.extractedFunc()
                
                user?.sendEmailVerification() { error in
                    self.alert.settingWithAct2(target: alertTarget, title: "帳號認證", message: "請在您的信箱裡驗證帳號", BTNtitle: "OK")
                }
                
            })
            
        })
    }
    
//    func signInFirebaseWithEmail(email: String, password: String, completion: @escaping (_ result: Result) -> ()){
//        
//        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
//            
//            if error != nil {
//                
//                print(error?.localizedDescription as Any)
//                return
//            }else{
//                completion(Result.success)
//            }
//            
//        })
//    }
//    
//    func forgetPasswordWithEmail(email: String){
//        Auth.auth().sendPasswordReset(withEmail: email) { error in
//            
//            if let error = error {
//                print(error.localizedDescription)
//            } else {
//                // 寄送新密碼
//            }
//        }
//    }
    
//    func uploadImageToStorage(image: UIImage, childName: String, completion: @escaping (_ result: String) -> ()){
//        
//        let imageName = NSUUID().uuidString
//        
//        let ref = FIRStorage.storage().reference().child(childName).child(imageName)
//        
//        if let uploadData = UIImageJPEGRepresentation(image, 1) {
//            
//            ref.put(uploadData, metadata: nil, completion: { (metadata, error) in
//                
//                if error != nil {
//                    print("Failed to upload image:", error!)
//                    return
//                }
//                
//                if let imageUrl = metadata?.downloadURL()?.absoluteString {
//                    completion(imageUrl)
//                }
//            })
//        }
//    }
    
    func uploadTextToDataBase(properties: [String: AnyObject],childName: String, completion: @escaping (_ result: Result) -> ()){
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child(childName).child(uid)
        
        let childRef = ref.childByAutoId() //隨機建立的id
        
        var properties = properties
        
        properties["Child ID"] = childRef.key as AnyObject
        
        childRef.updateChildValues(properties, withCompletionBlock: {
            (error, ref) in
            
            if error != nil{
                print(error!)
                return
            }else{
                
                completion(Result.success)
            }
            
        })
    }
    
    func removeDataFromFirebaseDataBase(childID: String,childName: String, completion: @escaping (_ result: Result) -> ()){
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        Database.database().reference().child(childName).child(uid).child(childID).removeValue(completionBlock: { (error, ref) in
            
            if error != nil{
                print(error!)
                return
            }else{
                
                completion(Result.success)
            }
        })
    }
    
    func fetchDataFromFirebaseDataBase(childName: String, completion: @escaping (_ data: [String: AnyObject], _ childID: String) -> ()){
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let reference = Database.database().reference().child(childName).child(uid)
        reference.observe(.childAdded, with: {
            (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                
                completion(dictionary, snapshot.key)
                
            }
            
        }, withCancel: nil)
    }
    
}
