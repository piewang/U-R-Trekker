//
//  CustomAnnotation.swift
//  Project
//
//  Created by pie wang on 2017/10/13.
//  Copyright © 2017年 Willy. All rights reserved.
//

import UIKit
import MapKit

class CustomAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var text:String!
    var city:String!
    var date:String!
    var image:UIImage!
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
