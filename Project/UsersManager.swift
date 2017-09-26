//
//  UsersManager.swift
//  Project
//
//  Created by Willy on 2017/9/26.
//  Copyright © 2017年 Willy. All rights reserved.
//

import Foundation

class UsersManager:CoreDataManager<Users> {
    
    private(set) var userItem:Users?
    
    static private(set) var shared:UsersManager?
    
    class func setAsSingleton(instance:UsersManager){
        shared = instance
    }
    
    func giveValue(toUserItem:Users) {
        userItem = toUserItem
    }
    
}
