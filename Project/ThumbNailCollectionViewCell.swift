//
//  ThumbNailCollectionViewCell.swift
//  WaterfallPractice
//
//  Created by Champion on 2017/9/2.
//  Copyright © 2017年 Champion. All rights reserved.
//

import UIKit

class ThumbNailCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleName: UILabel!
    
    var good:Data?
    
    func setGoodData(_ good:Data) {
        self.good = good
        let url = URL.init(string: good.img)
        self.imageView.sd_setImage(with: url)
        self.titleName.text = good.title
    }
}
