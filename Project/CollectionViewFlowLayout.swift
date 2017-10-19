//
//  CollectionViewFlowLayout.swift
//  WaterfallPractice
//
//  Created by Champion on 2017/9/2.
//  Copyright © 2017年 Champion. All rights reserved.
//

import UIKit


class CollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    var columnCount = 2    //總列數
    var goodlist = [Annotation]()   //準備商品陣列
    fileprivate var layoutAttributesArray = [UICollectionViewLayoutAttributes]()
    
    override func prepare() {
        minimumLineSpacing = 15
        minimumInteritemSpacing = 15
        sectionInset.top        = 10
        sectionInset.left       = 15
        sectionInset.right      = 15
        
        let contentWidth:CGFloat = (collectionView?.bounds.size.width)! - sectionInset.left - sectionInset.right
        let itemWidth = (contentWidth - minimumInteritemSpacing) / CGFloat.init(columnCount)
        computeAttributesWithItemWidth(CGFloat(itemWidth))
        
    }
    
    //根據item計算佈局屬性
    func computeAttributesWithItemWidth(_ itemWidth:CGFloat){
        
        //紀錄每一欄高度的陣列
        var columnHeight = [CGFloat](repeating: sectionInset.top, count: columnCount)
        //紀錄每欄item數量的陣列
        var columnItemCount = [CGFloat](repeating: 0, count: columnCount)
        //紀錄每個cell的attributes
        var attributesArray = [UICollectionViewLayoutAttributes]()
        
        var index = 0
        for good in self.goodlist {
            
            let pic = UIImage(data: good.imageData! as Data)
            var picture:UIImage?
            
            //判斷長寬比，若長比寬短則裁切圖片
            if (pic?.size.height)!/(pic?.size.width)! < 1 {
                let arrangeWidth = (pic?.size.width)! * ((pic?.size.height)!/(pic?.size.width)!)
                let imageRef = pic?.cgImage?.cropping(to: CGRect(x: 0, y: 0, width: 167, height: 150))
                picture = UIImage(cgImage: imageRef!)
            } else if (pic?.size.height)!/(pic?.size.width)! == 1 {
                let arrangeWidth = (pic?.size.width)! * ((pic?.size.height)!/(pic?.size.width)!)
                let imageRef = pic?.cgImage?.cropping(to: CGRect(x: 0, y: 0, width: 167, height: 167))
                picture = UIImage(cgImage: imageRef!)
            }else if  (pic?.size.height)!/(pic?.size.width)! > 1 {
                let arrangeWidth = (pic?.size.width)! * ((pic?.size.height)!/(pic?.size.width)!)
                let imageRef = pic?.cgImage?.cropping(to: CGRect(x: 0, y: 0, width: 167, height: 250))
                picture = UIImage(cgImage: imageRef!)
                
            } else {
                picture = pic
            }
            
            
            
            //建立一個attribute，用來做cell的layout
            let indexPath = IndexPath.init(item: index, section: 0)
            let attributes = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
            
            // 找出最短欄
            let minHeight = columnHeight.sorted().first!
            let column = columnHeight.index(of: minHeight)
            
            // 在最短欄加一
            columnItemCount[column!] += 1
            let itemX = (itemWidth + minimumInteritemSpacing) * CGFloat(column!) + sectionInset.left
            let itemY = minHeight
            
            // 等比例缩放 計算item的高度
            guard let pic1 = picture else {
                return
            }
            
            let itemH = pic1.size.height * itemWidth / pic1.size.width
            print(itemH)
            // 設置frame
            attributes.frame = CGRect(x: itemX, y: itemY, width: itemWidth, height: CGFloat(itemH))
            attributesArray.append(attributes)
            
            // 累加列高
            columnHeight[column!] += itemH + self.minimumLineSpacing
            index += 1
        }
        
        // 找出最高列
        let maxHeight = columnHeight.sorted().last!
        let column = columnHeight.index(of: maxHeight)
        // 根据最高列设置itemSize 使用總高度的平均值
        let itemH = (maxHeight - minimumLineSpacing * columnItemCount[column!]) / columnItemCount[column!]
        itemSize = CGSize(width: itemWidth, height: CGFloat(itemH))
        // 给屬性陣列設數值
        layoutAttributesArray = attributesArray
        
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        return layoutAttributesArray
    }
}

