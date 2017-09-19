//
//  HomeViewController+CIFilter.swift
//  Project
//
//  Created by Willy on 2017/9/15.
//  Copyright © 2017年 Willy. All rights reserved.
//

import Foundation
import CoreImage

extension HomeViewController {
    
    func addFilter(){
        guard let image = imageView?.image, let cgimg = image.cgImage else {
            print("imageView doesn't have an image!")
            return
        }
        let coreImage = CIImage(cgImage: cgimg)
        
        let filter = CIFilter(name: "CISepiaTone")
        filter?.setValue(coreImage, forKey: kCIInputImageKey)
        filter?.setValue(0.5, forKey: kCIInputIntensityKey)
        
        if let output = filter?.value(forKey: kCIOutputImageKey) as? CIImage {
            let filteredImage = UIImage(ciImage: output)
            imageView?.image = filteredImage
        }
            
        else {
            print("image filtering failed")
        }
    }
    
}
