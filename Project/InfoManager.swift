//
//  InfoManager.swift
//  testtest
//
//  Created by Daniel on 2017/9/19.
//  Copyright © 2017年 Daniel. All rights reserved.
//

import Foundation

class InfoManager: CoreDataManager<Info> {
    
    static private(set) var shared:InfoManager?
    
    class func setAsSingleton(instance:InfoManager){
        shared = instance
    }

}
