//
//  ViewController.swift
//  WaterfallPractice
//
//  Created by Champion on 2017/9/1.
//  Copyright © 2017年 Champion. All rights reserved.
//

import UIKit
import CoreData

class MyRecordViewController: UICollectionViewController {
    
    @IBOutlet weak var flowLayout: CollectionViewFlowLayout!

    var goodlist = [Annotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        // Do any additional setup after loading the view, typically from a nib.
//        makeGoodArray()
        print(goodlist.count)
        flowLayout.goodlist = goodlist
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return goodlist.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ThumbNailCollectionViewCell
        
        if let image = goodlist[indexPath.row].imageData {
            cell.imageView.image = UIImage(data: image as Data)
        }
        
        cell.caption.text = goodlist[indexPath.row].text
        cell.layer.cornerRadius = 4.0
        cell.clipsToBounds = true
        
        return cell;
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc2 = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        vc2.annotation = goodlist[indexPath.row]
        navigationController?.pushViewController(vc2, animated: true)
    }
}

