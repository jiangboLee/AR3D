//
//  ViewController.swift
//  FrontAndBack
//
//  Created by Lee on 2018/9/19.
//  Copyright © 2018年 Lee. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var planeNode: SCNNode?
    var floorNode: SCNNode?
    var planeGeometry: SCNPlane?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScece()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        runWorldTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func setupScece() {
        sceneView.delegate = self
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/bg.scn")!
        // Set the scene to the view
        sceneView.scene = scene
    }
    func runWorldTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    
    @IBAction func wantPlanClickAction(_ sender: Any) {
        
        guard let pointOfView = sceneView.pointOfView else { return }
        let transform = pointOfView.transform
        let orientation = SCNVector3Make(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3Make(transform.m41, transform.m42, transform.m43 - 5)
        let currentPositionOfCamera = orientation + location
        
        let scene = SCNScene(named: "art.scnassets/ship.scn")
        planeNode = scene?.rootNode.childNode(withName: "ship", recursively: false)
        planeNode?.position = currentPositionOfCamera
        sceneView.scene.rootNode.addChildNode(planeNode!)
    }
    
    @IBAction func goFrontClickAction(_ sender: Any) {
        guard let _ = planeNode else { return }
        runActionForPlaneNode(withDistance: 1)
    }
    
    @IBAction func goBackClickAction(_ sender: Any) {
        guard let _ = planeNode else { return }
        runActionForPlaneNode(withDistance: -1)
    }
    
    private func runActionForPlaneNode(withDistance distance: Float) {
        let action = SCNAction.move(by: SCNVector3Make(0, 0, distance), duration: 1)
        planeNode!.runAction(action)
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        floorNode = createFloor(for: planeAnchor)
        setTextureScale()
        node.addChildNode(floorNode!)
        print("addaddaddaddaddaddaddaddaddadd")
    }
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        update(planeAnchor: planeAnchor)
        print("didUpdatedidUpdatedidUpdatedidUpdatedidUpdate")
    }
    
    func createFloor(for planeAnchor: ARPlaneAnchor) -> SCNNode {
        planeGeometry = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
    
        let img = UIImage(named: "tron_grid")
        planeGeometry?.firstMaterial?.diffuse.contents = img
        planeGeometry?.firstMaterial?.isDoubleSided = true
        let floorNode = SCNNode(geometry: planeGeometry!)
        floorNode.position = SCNVector3(planeAnchor.center.x,
                                        planeAnchor.center.y,
                                        planeAnchor.center.z)
        floorNode.eulerAngles = SCNVector3(90.degreesToRadians, 0, 0)
        let staticBody = SCNPhysicsBody.static()
        floorNode.physicsBody = staticBody
        return floorNode
    }
    
    func update(planeAnchor: ARPlaneAnchor) {
        
        planeGeometry?.width = CGFloat(planeAnchor.extent.x)
        planeGeometry?.height = CGFloat(planeAnchor.extent.z)
        floorNode?.position = SCNVector3(planeAnchor.center.x,
                                         planeAnchor.center.y,
                                         planeAnchor.center.z)
        setTextureScale()
    }
    
    func setTextureScale() {
        
        let width = planeGeometry?.width ?? 0
        let height = planeGeometry?.height ?? 0
        // 平面的宽度/高度 width/height 更新时，我希望 tron grid material 覆盖整个平面，不断重复纹理。
        // 但如果网格小于 1 个单位，我不希望纹理挤在一起，所以这种情况下通过缩放更新纹理坐标并裁剪纹理
        let material = planeGeometry?.materials.first
        material?.diffuse.contentsTransform = SCNMatrix4MakeScale(Float(width), Float(height), 1)
        material?.diffuse.wrapS = .repeat
        material?.diffuse.wrapT = .repeat
    }
   
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.x + right.y, left.z + right.z)
}
extension Int {
    var degreesToRadians: Double { return Double(self) * .pi/180}
}

