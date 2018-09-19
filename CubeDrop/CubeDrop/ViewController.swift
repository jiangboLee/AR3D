//
//  ViewController.swift
//  CubeDrop
//
//  Created by Lee on 2018/9/19.
//  Copyright © 2018年 Lee. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var boxes = [SCNNode]()
    var planes = [UUID: Plane]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
        setupRecognizers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func setupScene() {
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.automaticallyUpdatesLighting = true
        
        // 开启 debug 选项以查看世界原点并渲染所有 ARKit 正在追踪的特征点
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        // Create a new scene
        let scene = SCNScene()
        // Set the scene to the view
        sceneView.scene = scene
    }
    func setupSession() {
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
    }

    func setupRecognizers() {
        // 轻点一下就会往场景中插入新的几何体
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapFrom(recognizer:)))
        tap.numberOfTapsRequired = 1
        sceneView.addGestureRecognizer(tap)
    }
    @objc func handleTapFrom(recognizer: UITapGestureRecognizer) {
        // 获取屏幕空间坐标并传递给 ARSCNView 实例的 hitTest 方法
        let tapPoint = recognizer.location(in: sceneView)
        let result = sceneView.hitTest(tapPoint, types: .existingPlaneUsingExtent)
        // 如果射线与某个平面几何体相交，就会返回该平面，以离摄像头的距离升序排序
        // 如果命中多次，用距离最近的平面
        if let hitResult = result.first {
            insertGeometry(hitResult)
        }
    }
    
    func insertGeometry(_ hitResult: ARHitTestResult) {
        // 现在先插入简单的小方块，后面会让它变得更好玩，有更好的纹理和阴影
        let dimension: CGFloat = 0.1
        let cube = SCNBox(width: dimension, height: dimension, length: dimension, chamferRadius: 0)
        let node = SCNNode(geometry: cube)
        
        // physicsBody 会让 SceneKit 用物理引擎控制该几何体
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        node.physicsBody?.mass = 2
        node.physicsBody?.categoryBitMask = 1
        
        // 把几何体插在用户点击的点再稍高一点的位置，以便使用物理引擎来掉落到平面上
        let insertionYOffset: Float = 0.5
        node.position = SCNVector3Make(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y + insertionYOffset, hitResult.worldTransform.columns.3.z)
        sceneView.scene.rootNode.addChildNode(node)
        boxes.append(node)
    }
    //停止平面检测
    func stopSession() {
        if let configuration = sceneView.session.configuration as? ARWorldTrackingConfiguration {
            configuration.planeDetection = .init(rawValue: 0)
            sceneView.session.run(configuration)
        }
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor else { return }
        // 检测到新平面时创建 SceneKit 平面以实现 3D 视觉化
        let plane = Plane(withAnchor: anchor, isHidden: false)
        planes[anchor.identifier] = plane
        node.addChildNode(plane)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let plane = planes[anchor.identifier] else { return }
        plane.update(anchor: anchor as! ARPlaneAnchor)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        planes.removeValue(forKey: anchor.identifier)
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
