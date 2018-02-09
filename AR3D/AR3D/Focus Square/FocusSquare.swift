//
//  FocusSquare.swift
//  AR3D
//
//  Created by ljb48229 on 2018/2/8.
//  Copyright © 2018年 ljb48229. All rights reserved.
//

import UIKit
import ARKit

class FocusSquare: SCNNode {
    
    // MARK: - Configuration Properties 配置属性
    
    // Original size of the focus square in meters.
    // 聚焦框的原始尺寸,单位是米.
    static let size: Float = 0.17
    
    // Thickness of the focus square lines in meters.
    // 聚焦框的线宽,单位是米.
    static let thickness: Float = 0.018
    
    // Scale factor for the focus square when it is closed, w.r.t. the original size.
    // 当聚焦框关闭状态时的缩放因子,原始尺寸.
    static let scaleForClosedSquare: Float = 0.97
    
    // Side length of the focus square segments when it is open (w.r.t. to a 1x1 square).
    // 当聚焦框打开状态时边的长度
    static let sideLengthForOpenSegments: CGFloat = 0.2
    
    // Duration of the open/close animation
    // 开启/关闭动画的时长.
    static let animationDuration = 0.7
    
    static let primaryColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
    //聚焦框填充颜色.
    static let fillColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
    
    /// 聚焦框中的线段列表.
    private var segments: [FocusSquare.Segment] = []
    /// 控制其他`FocusSquare`节点位置的主节点.
    private let positioningNode = SCNNode()
    
    override init() {
        super.init()
        opacity = 0.0
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
        let s1 = Segment(name: "s1", corner: .topLeft, alignment: .horizontal)
        let s2 = Segment(name: "s2", corner: .topRight, alignment: .horizontal)
        let s3 = Segment(name: "s3", corner: .topLeft, alignment: .vertical)
        let s4 = Segment(name: "s4", corner: .topRight, alignment: .vertical)
        let s5 = Segment(name: "s5", corner: .bottomLeft, alignment: .vertical)
        let s6 = Segment(name: "s6", corner: .bottomRight, alignment: .vertical)
        let s7 = Segment(name: "s7", corner: .bottomLeft, alignment: .horizontal)
        let s8 = Segment(name: "s8", corner: .bottomRight, alignment: .horizontal)
        segments = [s1, s2, s3, s4, s5, s6, s7, s8]
        
        let sl: Float = 0.5 //segment length 线段长
        let c: Float = FocusSquare.thickness / 2 // 纠正线段,使其完美对齐.
        s1.simdPosition += float3(-(sl / 2 - c), -(sl - c), 0)
        s2.simdPosition += float3(sl / 2 - c, -(sl - c), 0)
        s3.simdPosition += float3(-sl, -sl / 2, 0)
        s4.simdPosition += float3(sl, -sl / 2, 0)
        s5.simdPosition += float3(-sl, sl / 2, 0)
        s6.simdPosition += float3(sl, sl / 2, 0)
        s7.simdPosition += float3(-(sl / 2 - c), sl - c, 0)
        s8.simdPosition += float3(sl / 2 - c, sl - c, 0)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
