//
//  StringExtension.swift
//  FaceAR
//
//  Created by LEE on 2018/9/22.
//  Copyright © 2018年 Lee. All rights reserved.
//

import UIKit

extension String {
    
    func image() -> UIImage? {
        
        let size = CGSize(width: 20, height: 22)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.clear.set()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(CGRect(origin: .zero, size: size))
        
        (self as AnyObject).draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: 15)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
