//
//  LocationManager.swift
//  Project
//
//  Created by pie wang on 2017/9/30.
//  Copyright © 2017年 Willy. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager {
    static let shared = LocationManager()
    private let CLL = CLLocationManager()
    
    func showCLLocation() -> CLLocationManager {
        return CLL
    }
    private init() { }
}
