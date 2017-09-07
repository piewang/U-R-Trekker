//
//  ViewController.swift
//  Project
//
//  Created by Willy on 2017/9/5.
//  Copyright © 2017年 Willy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    let gesture = GestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        gesture.turnOnMenu(target: menuButton, VCtarget: self)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

