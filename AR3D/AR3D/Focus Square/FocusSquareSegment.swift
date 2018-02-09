//
//  FocusSquareSegment.swift
//  AR3D
//
//  Created by ljb48229 on 2018/2/8.
//  Copyright © 2018年 ljb48229. All rights reserved.
//

import UIKit
import SceneKit

extension FocusSquare {
    /*
     The focus square consists of eight segments as follows, which can be individually animated.
     聚焦框包含了下面的八个线段,各个线段可以有单独的动画效果.
     
     s1  s2
     _   _
     s3 |     | s4
     
     s5 |     | s6
     -   -
     s7  s8
     */
    enum Corner {
        case topLeft // s1, s3
        case topRight // s2, s4
        case bottomRight // s6, s8
        case bottomLeft // s5, s7
    }
    
    enum Alignment {
        case horizontal // s1, s2, s7, s8
        case vertical // s3, s4, s5, s6
    }
    
    enum Direction {
        case up, down, left, right
        
        var reversed: Direction {
            switch self {
            case .up:
                return .down
            case .down:
                return .up
            case .left:
                return .right
            case .right:
                return .left
            }
        }
    }
    
    class Segment: SCNNode {
        // 聚焦框线段的线宽,单位是米.
        static let thickness: CGFloat = 0.018
        /// 聚焦框线段的线长,单位是米
        static let length: CGFloat = 0.5  // segment length
        /// 打开状态时聚焦框线段的边的长度
        static let openLength: CGFloat = 0.2
        
        let corner: Corner
        let alignment: Alignment
        let plane: SCNPlane
        
        init(name: String, corner:Corner, alignment: Alignment) {
            self.corner = corner
            self.alignment = alignment
            
            switch alignment {
            case .vertical:
                plane = SCNPlane(width: Segment.thickness, height: Segment.length)
            case .horizontal:
                plane = SCNPlane(width: Segment.length, height: Segment.thickness)
            }
            super.init()
            self.name = name
            
            let material = plane.firstMaterial!
            material.diffuse.contents = FocusSquare.primaryColor
            //确定接收器是否是双面的。默认为NO.
            material.isDoubleSided = true
            //环境属性指定要反射的环境光的数量。此属性对没有环境光的场景没有视觉影响.
            material.ambient.contents = UIColor.black
            material.lightingModel = .constant
            material.emission.contents = FocusSquare.primaryColor
            geometry = plane
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
}
















