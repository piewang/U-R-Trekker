//
//  DispatchQueue+Once.swift
//  Project
//
//  Created by pie wang on 2017/9/11.
//  Copyright © 2017年 Willy. All rights reserved.
//

import Foundation



extension DispatchQueue {
    // 但允許擴充靜態變數
    // static 表示程式一啟動時，會為 static 配置一塊空間 直到 app 砍掉
    static var onceTokens = [String]()
    
    class func once(token:String, job:() -> Void) {
        
        objc_sync_enter(self)
        defer{
            objc_sync_exit(self)
        }
        if onceTokens.contains(token) {
            return
        }
        onceTokens.append(token)
        job()
    }
}

