//
//  InsertStopViewController.swift
//  Project
//
//  Created by pie wang on 2017/10/2.
//  Copyright © 2017年 Willy. All rights reserved.
//

import UIKit

class InsertStopViewController: UIViewController, UINavigationControllerDelegate, UITextViewDelegate  {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var midView: UIView!
    @IBOutlet weak var addPhotoImageView: UIImageView!
    @IBOutlet weak var addPhotoLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var heightOfBox: NSLayoutConstraint!
    @IBOutlet weak var boxView: UIView!
    @IBOutlet weak var heightOfMidView: NSLayoutConstraint!
    
//    let runManager = CoreDataManager<Run>(momdFilename: "InfoModel", entityName: "Run", sortKey: "timestamp")
    let annotationManager = CoreDataManager<Annotation>(momdFilename: "InfoModel", entityName: "Annotation", sortKey: "timestamp")
    
    var photoImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 顯示使用者名稱＆照片
        let name = usersDataManager.userItem?.name
        userNameLabel.text = name
        if let userImgUserURLString = usersDataManager.userItem?.photo {
            let userImgURL = URL(string:userImgUserURLString)
            let userImgData = NSData(contentsOf: userImgURL! )
            let userImage = UIImage(data: userImgData! as Data)
            userImageView.image = userImage
        } else {
            userImageView.image = UIImage(named:"userDefaultImage.png")
        }
        userImageView.layer.cornerRadius = 25
        userImageView.layer.masksToBounds = true
   
            
            
        // 提示使用者可以增加照片
        addPhotoLabel.text = "增加照片！"
        // Prepare BarButtonItem
        addBarButtonItem()
        // Prepare textView
        textViewSetting(textView: textView)
        
        // 收起鍵盤設定
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        self.view .addGestureRecognizer(tapGesture)
    }
    
    /// deinit
    override func viewDidDisappear(_ animated: Bool) {
        ///...
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addPhotoBtnPressed(_ sender: Any) {
        addPhotoAlert()
    }
    
    
    @objc func done()  {
        editAnnotation(originalItem: nil) { (success, item) in
            guard success == true else {
                return
            }
            do {
                try usersDataManager.runItem?.managedObjectContext?.save()
                try usersDataManager.userItem?.managedObjectContext?.save()
            } catch {
                let error = error as NSError
                assertionFailure("Unresolve error\(error)")
            }
        }
        navigationController?.popViewController(animated: true)
        print(usersDataManager.runItem?.annotations?.count)
        
    }
    
    @objc func cancel() {
        textView.text = ""
        imageView.image = nil
        navigationController?.popViewController(animated: true)
    }
    
    @objc func tap(_ sender:Any) {
        self.view.endEditing(true)
    }
    

    
    
    
   

}

extension InsertStopViewController {
    
    func textViewSetting(textView: UITextView) {
        textView.placeholder = "新增留言在您的紀錄吧！"
        textView.font = UIFont(name: (textView.font?.fontName)!, size: 20)
        
        heightOfBox.constant = 277
        imageView.isHidden = true
        addPhotoImageView.image = UIImage(named:"addPhoto.png")
    }
    
    func addBarButtonItem() {
        let okBtn = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(done))
        okBtn.tintColor = UIColor.white
        navigationItem.rightBarButtonItem? = okBtn
        let cancelBtn = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        cancelBtn.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = cancelBtn
    }
    
}


extension InsertStopViewController: UIImagePickerControllerDelegate {
    
    func launchImagePicker(sourceType: UIImagePickerControllerSourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) == false {
            NSLog("No Available Device")
            return
        }
        // Prepare UIimagePicker
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.mediaTypes = ["public.image","public.movie"]
        picker.delegate = self
        self.present(picker, animated: true, completion: nil
        )
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        boxViewAnimate()
        picker.dismiss(animated: true, completion: nil)
        photoImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        imageView.image = photoImage
        
        
    }
    func addPhotoAlert() {
        let alert = UIAlertController(title: "新增照片", message: nil, preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "相機", style: .default) {_ in
            self.launchImagePicker(sourceType: .camera)
        }
        let library = UIAlertAction(title: "相簿", style: .default) {_ in
            self.launchImagePicker(sourceType: .photoLibrary)
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel) {_ in
            self.boxViewAnimate()
        }
        
        alert.addAction(camera)
        alert.addAction(library)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func boxViewAnimate() {
        if heightOfBox.constant < 300 {
            heightOfMidView.constant = 5
            heightOfBox.constant = 603
            self.midView.isHidden = true
            self.addPhotoImageView.isHidden = true
            self.addPhotoLabel.isHidden = true
            UIView.animate(withDuration: 0.5, animations: {
                self.boxView.frame.origin.y += 163
                self.boxView.layoutIfNeeded()
                self.midView.layoutIfNeeded()
            }, completion: {_ in
                self.imageView.isHidden = false
                
                
            })
        } else {
            heightOfBox.constant = 277
            heightOfMidView.constant = 59
            UIView.animate(withDuration: 0.5, animations: {
                self.boxView.frame.origin.y -= 163
                self.boxView.layoutIfNeeded()
                self.midView.layoutIfNeeded()
            }, completion: {_ in
                self.imageView.isHidden = true
                self.midView.isHidden = false
                self.addPhotoImageView.isHidden = false
                self.addPhotoLabel.isHidden = false
            })
            
        }
    }
}

// CoreData Annotation
extension InsertStopViewController {
    typealias EditDoneHandler = (_ success:Bool, _ resultItem:Annotation?) -> Void
    
    func editAnnotation(originalItem: Annotation?, completion: EditDoneHandler) {
        var finalItem = originalItem
        if finalItem == nil {
            finalItem = annotationManager.createItemTo(target: usersDataManager.runItem!)
            usersDataManager.runItem?.addToAnnotations(finalItem!)
        }
        if let text = textView.text {
            finalItem?.text = text
        }
        if let image = imageView.image {
            finalItem?.imageData = UIImagePNGRepresentation(image)
        }
        completion(true, finalItem)
    }
}
















