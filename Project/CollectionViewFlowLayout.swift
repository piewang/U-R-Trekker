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
    var goodlist = [Info]()   //準備商品陣列
    fileprivate var layoutAttributesArray = [UICollectionViewLayoutAttributes]()
    
    override func prepare() {
        minimumLineSpacing = 25
        
        let contentWidth:CGFloat = (self.collectionView?.bounds.size.width)! - self.sectionInset.left - self.sectionInset.right
        let marginX = self.minimumInteritemSpacing
        let itemWidth = (contentWidth - marginX * 2.0) / CGFloat.init(self.columnCount)
        self.computeAttributesWithItemWidth(CGFloat(itemWidth))
        
    }
    
    //根據item計算佈局屬性
    func computeAttributesWithItemWidth(_ itemWidth:CGFloat){
        //紀錄每一列高度的陣列
        var columnHeight = [CGFloat](repeating: sectionInset.top, count: columnCount)
        //紀錄每列總item的陣列
        var columnItemCount = [CGFloat](repeating: 0, count: columnCount)
        var attributesArray = [UICollectionViewLayoutAttributes]()
        
        var index = 0
        for good in self.goodlist {

            let good = UIImage(data: good.image! as Data)

            let indexPath = IndexPath.init(item: index, section: 0)
            let attributes = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
            // 找出最短列
            let minHeight = columnHeight.sorted().first!
            let column = columnHeight.index(of: minHeight)
            // 在最短列加一
            columnItemCount[column!] += 1
            let itemX = (itemWidth + self.minimumInteritemSpacing) * CGFloat(column!) + self.sectionInset.left
            let itemY = minHeight
            // 等比例缩放 計算item的高度
            guard let good1 = good else {
                return
            }
            let itemH = good1.size.height * itemWidth / good1.size.width
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
        // 根据最高列设置itemSize 使用总高度的平均值
        let itemH = (maxHeight - minimumLineSpacing * columnItemCount[column!]) / columnItemCount[column!]
        self.itemSize = CGSize(width: itemWidth, height: CGFloat(itemH))
        // 给屬性陣列設數值
        self.layoutAttributesArray = attributesArray

    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

        return self.layoutAttributesArray
    }
}

