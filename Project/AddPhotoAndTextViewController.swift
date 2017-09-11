//
//  AddPhotoAndTextViewController.swift
//  Project
//
//  Created by pie wang on 2017/9/11.
//  Copyright © 2017年 Willy. All rights reserved.
//

import UIKit

class AddPhotoAndTextViewController: UIViewController {

    @IBOutlet weak var askAddPhotoLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet var tapImageToCamera: UITapGestureRecognizer!
    
    
    var textEntered:String?
    var photoImage:UIImage?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoImageView.image = photoImage
        
        if photoImageView.image == UIImage(named:"default") {
            askAddPhotoLabel.text = "Do you want to add a image?"
        } else {
            askAddPhotoLabel.text = "You picked a image."
        }
        
        textView.text = textEntered
        
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func saveBtnPressed(_ sender: Any) {
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
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
