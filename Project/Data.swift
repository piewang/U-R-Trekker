//
//  Data.swift
//  WaterfallPractice
//
//  Created by Champion on 2017/9/4.
//  Copyright © 2017年 Champion. All rights reserved.
//

import Foundation

class Data:NSObject {
    
    var w:Int = 0
    var h:Int = 0
    var title = ""
    var img = ""
    
    static func goodWithDict(_ dic:NSDictionary ) -> Data {
        let good =  Data.init()
        good.setValuesForKeys(dic as! [String : AnyObject])
        return good
    }
    
    // 根据索引返回商品数组
    static func goodsWithIndex(_ index:Int8) -> NSArray {
        let fileName = "\(index)"
        let path = Bundle.main.path(forResource: fileName, ofType: "plist")
        print(path)
        let goodsAry = NSArray.init(contentsOfFile: path!)
        print(goodsAry)
        let goodsArray = goodsAry?.map{self.goodWithDict($0 as! NSDictionary)}
        print(goodsArray)
        return goodsArray! as NSArray
    }

    
}
