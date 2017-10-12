//
//  DetailViewController.swift
//  Project
//
//  Created by Champion on 2017/10/2.
//  Copyright © 2017年 Willy. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var text: UITextView!
    @IBOutlet weak var contentView: UIView!
    
    var annotation = Annotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgView.image = UIImage(data: annotation.imageData as! Data)
        text.text = annotation.text
        self.navigationController?.navigationBar.isTranslucent = true
        //圓角和陰影
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 5.0
        self.contentView.layer.shadowColor = UIColor.black.cgColor
        self.contentView.layer.shadowOpacity = 1
        self.contentView.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.contentView.layer.shadowRadius = 3
        self.contentView.layer.shadowPath = UIBezierPath(rect: self.contentView.bounds).cgPath
        self.contentView.layer.shouldRasterize = true
        self.contentView.layer.rasterizationScale = UIScreen.main.scale
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
