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
    
    var goodlist = [Info]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        makeGoodArray()
        print(goodlist.count)
        flowLayout.goodlist = goodlist
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func makeGoodArray(){
        guard let totals = usersDataManager.userItem?.info?.count else {
            return
        }
        guard totals != 0 else {
            return
        }
        let total = totals - 1
        for num in 0...total{
            if let items = usersDataManager.userItem?.info?.allObjects {
                
                let item = items[num] as! Info
                
                goodlist.append(item)
            }
        }
    }

    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return goodlist.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ThumbNailCollectionViewCell
        
        if let image = goodlist[indexPath.row].image {
            cell.imageView.image = UIImage(data: image as Data)
        }
        
        cell.caption.text = goodlist[indexPath.row].content
        
        //        if let text = goodlist[indexPath.row].content {
        //            cell.titleName.text = text
        //        }
        return cell;
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc2 = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        vc2.info = goodlist[indexPath.row]
        navigationController?.pushViewController(vc2, animated: true)
    }
}

