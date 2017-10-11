//
//  DetailViewController.swift
//  Project
//
//  Created by Champion on 2017/10/2.
//  Copyright © 2017年 Willy. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    
    @IBOutlet weak var backgroundImgView: UIImageView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var text: UITextView!
    @IBOutlet weak var contentView: UIView!
    
    var annotation = Annotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageView = UIImage(data: annotation.imageData as! Data)
        backgroundImgView.image = imageView
        text.text = annotation.text
        if (imageView?.size.height)!/(imageView?.size.width)! <= 1 {
            let imageRef = pic?.cgImage?.cropping(to: CGRect(x: 0, y: 0, width: 167, height: 216))
            imgView.image = UIImage(cgImage: imageRef!)
        } else {
            imgView.image = imageView
        }
        self.navigationController?.navigationBar.isTranslucent = true
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 5.0
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
