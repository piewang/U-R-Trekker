//
//  ViewController.swift
//  WaterfallPractice
//
//  Created by Champion on 2017/9/1.
//  Copyright © 2017年 Champion. All rights reserved.
//

import UIKit

class MyRecordViewController: UICollectionViewController {
    
    var goodsList = [Data]()
    var index = 1
    
    
    @IBOutlet weak var flowLayout: CollectionViewFlowLayout!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.collectionView?.backgroundColor = UIColor.white
        self.loadData()
        
    }
    
    func loadData() {
        let goods = Data.goodsWithIndex(Int8(self.index))
        self.goodsList.append(contentsOf: goods as! [Data])
        self.flowLayout.columnCount = 2
        self.flowLayout.goodslist = self.goodsList
        self.collectionView?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.goodsList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ThumbNailCollectionViewCell
        cell.setGoodData(self.goodsList[(indexPath as NSIndexPath).item])
        return cell;
    }
}

