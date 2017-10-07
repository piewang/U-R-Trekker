//
//  AddPhotoAndTextViewController.swift
//  Project
//
//  Created by pie wang on 2017/9/11.
//  Copyright © 2017年 Willy. All rights reserved.
//

import UIKit

class AddPhotoAndTextViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var askAddPhotoLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet var tapImageToCamera: UITapGestureRecognizer!
    @IBOutlet weak var addTextLabel: UILabel!
    
    @IBOutlet weak var keyboardHide: UIButton!
    var textEntered:String?
    var photoImage:UIImage?
    let defaultImage = UIImage(named: "defaultImage")
    let backgroundColor = Color()
    
    fileprivate var isKeyboardShown = false
    /////////////
    let infoManager = CoreDataManager<Info>(momdFilename: "InfoModel", entityName: "Info", sortKey: "date")
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /////////////
        usersDataManager = UsersManager.shared
        
        keyboardHide.isHidden = true
        
        titleLabel.text = "新增記錄！"
        addTextLabel.text = "新增留言"
        
        self.navigationItem.hidesBackButton = true
        
        backgroundColor.colorSetting2(target: containerView)

        photoImageView.layer.cornerRadius = 10
        photoImageView.layer.masksToBounds = true
        
        if photoImage == nil {
            askAddPhotoLabel.text = "試試在您的軌跡記錄上新增照片！ "
            photoImageView.image = defaultImage
            
        } else {
            askAddPhotoLabel.textColor = UIColor.black
            askAddPhotoLabel.text = "您已選擇一張照片！"
            photoImageView.image = photoImage
        }
        askAddPhotoLabel.font = UIFont(name: "Chalkboard SE", size: 18)
        
        textView.layer.cornerRadius = 10
        textView.layer.masksToBounds = true
        
        textView.text = textEntered
        
        // MARK: NotificaitonCenter
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        
        editInfo(originalItem: nil) { (success, item) in
            
            guard success == true else {
                return
            }
            
            do{
                try usersDataManager.userItem?.managedObjectContext?.save()
            } catch {
                let nserror = error as NSError
                //在debug模式下會停止程式
                assertionFailure("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        textView.text = ""
        photoImageView.image = nil
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func keyboardBtnPressed(_ sender: Any) {
        self.textView.endEditing(true)
    }
    @IBAction func tapImagePressed(_ sender: Any) {
        // 跳出 alert 視窗
        let alert = UIAlertController(title: "Add new Photo?", message: "Taking a pic from camera, or pick from photo library", preferredStyle: .actionSheet)
        // 相機
        let camera = UIAlertAction(title: "Camera", style: .default) { (_) in
            
            self.launchImagePicker(sourceType: .camera)
        }
        // 相簿
        let library = UIAlertAction(title: "Library", style: .default) { (_) in
            self.launchImagePicker(sourceType: .photoLibrary)
        }
        // 取消
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(camera)
        alert.addAction(library)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }

    func launchImagePicker(sourceType: UIImagePickerControllerSourceType) {
        // 檢查硬體設備是否相同 sourceType
        if UIImagePickerController.isSourceTypeAvailable(sourceType) == false {
            NSLog("No Available Device")
            return
        }
        // Prepare UIImagePicker
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.mediaTypes = ["public.image","public.movie"]
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        photoImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        photoImageView.image = photoImage
        askAddPhotoLabel.text = "You picked a image."
        
    }
    
    
    // MARK: Keboard Show And Hide
    @objc func keyboardWillShow(_ note: Notification) {
        if isKeyboardShown {
            return
        }
        keyboardHide.isHidden = false
        
        let keyboardAnimationDetail = note.userInfo as! [String: AnyObject]
        let duration = TimeInterval(truncating: keyboardAnimationDetail[UIKeyboardAnimationDurationUserInfoKey]! as! NSNumber)
        let keyboardFrameValue = keyboardAnimationDetail[UIKeyboardFrameBeginUserInfoKey]! as! NSValue
        let keyboardFrame = keyboardFrameValue.cgRectValue
        
        UIView.animate(withDuration: duration, animations: { () -> Void in
            self.view.frame = self.view.frame.offsetBy(dx: 0, dy: -keyboardFrame.size.height)

            
            
        })
        isKeyboardShown = true
    }
    
    @objc func keyboardWillHide(_ note: Notification) {
        
        keyboardHide.isHidden = true
        let keyboardAnimationDetail = note.userInfo as! [String: AnyObject]
        let duration = TimeInterval(truncating: keyboardAnimationDetail[UIKeyboardAnimationDurationUserInfoKey]! as! NSNumber)
        UIView.animate(withDuration: duration, animations: { () -> Void in
            self.view.frame = self.view.frame.offsetBy(dx: 0, dy: -self.view.frame.origin.y)

        })
        isKeyboardShown = false
    }
    //MARK: - EdiInfo
    typealias EditDoneHandler = (_ success:Bool,_ resultItem:Info?) -> Void
    
    func editInfo(originalItem:Info?,completion:@escaping EditDoneHandler) {
        var finalItem = originalItem
        if finalItem == nil {
            //把Info存在與Users同一個context里
            finalItem = infoManager.createItemTo(target: usersDataManager.userItem!)
            finalItem?.date = NSDate() as Date
            
            usersDataManager.userItem?.addToInfo(finalItem!)
        }
        if let word = textView.text {
            finalItem?.content = word
        }
        if let image = photoImageView.image {
            finalItem?.image = UIImagePNGRepresentation(image)
        }
        completion(true,finalItem)
    }

    

    
}
