//
//  DataManager.swift
//  Project
//
//  Created by Willy on 2017/9/4.
//  Copyright © 2017年 Willy. All rights reserved.
//

import UIKit

class DataManager {
    
    static let sharedDataManager = DataManager()
    
    private init() {}
    
    private let list = ["探險","我的足跡","設定"]
    
    func count() -> Int{
        return list.count
    }
    
    func listByIndex(index:Int) -> String {
        if index < 0 || index >= list.count {
           print("======listIndex errow======")
        }
        return list[index]
    }
    
}


