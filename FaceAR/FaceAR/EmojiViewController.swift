//
//  EmojiViewController.swift
//  FaceAR
//
//  Created by Lee on 2018/9/21.
//  Copyright © 2018年 Lee. All rights reserved.
//

import UIKit
import ARKit

class EmojiViewController: UIViewController {
    
    @IBOutlet var scenceView: ARSCNView!
    
    let noseOptions = ["👃", "🐽", "💧", " "]
    let eyeOptions = ["👁", "🌕", "🌟", "🔥", "⚽️", "🔎", " "]
    let mouthOptions = ["👄", "👅", "❤️", " "]
    let hatOptions = ["🎓", "🎩", "🧢", "⛑", "👒", " "]
    let features = ["nose", "leftEye", "rightEye", "mouth", "hat"]
    let featureIndices = [[9], [1064], [42], [24, 25], [20]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError()
        }
        scenceView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARFaceTrackingConfiguration()
        scenceView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scenceView.session.pause()
    }
    
    func updateFeatures(for node: SCNNode, using anchor: ARFaceAnchor) {
        for (feature, indices) in zip(features, featureIndices) {
            let child = node.childNode(withName: feature, recursively: false) as? EmojiNode
            let vertices = indices.map{ anchor.geometry.vertices[$0] }
            child?.updatePosition(for: vertices)
            
            switch feature {
            case "leftEye":
                let scaleX = child?.scale.x ?? 1.0
                let eyeBlinkValue = anchor.blendShapes[.eyeBlinkLeft]?.floatValue ?? 0.0
                child?.scale = SCNVector3(scaleX, 1.0 - eyeBlinkValue, 1.0)
            case "rightEye":
                let scaleX = child?.scale.x ?? 1.0
                let eyeBlinkValue = anchor.blendShapes[.eyeBlinkRight]?.floatValue ?? 0.0
                child?.scale = SCNVector3(scaleX, 1.0 - eyeBlinkValue, 1.0)
            case "mouth":
                let jawOpenValue = anchor.blendShapes[.jawOpen]?.floatValue ?? 0.2
                child?.scale = SCNVector3(1.0, 0.8 + jawOpenValue, 1.0)
            default:
                break
            }
        }
    }

    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        
        let location = sender.location(in: scenceView)
        let results = scenceView.hitTest(location, options: nil)
        if let result = results.first,
            let node = result.node as? EmojiNode {
            node.next()
        }
    }
    
}

extension EmojiViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let faceAnchor = anchor as? ARFaceAnchor,
            let device = scenceView.device else { return nil }
        let faceGeometry = ARSCNFaceGeometry(device: device)
        let node = SCNNode(geometry: faceGeometry)
        node.geometry?.firstMaterial?.fillMode = .lines
        
        node.geometry?.firstMaterial?.transparency = 0.0
        let noseNode = EmojiNode(with: noseOptions)
        noseNode.name = features[0]
        node.addChildNode(noseNode)
        
        let leftEyeNode = EmojiNode(with: eyeOptions)
        leftEyeNode.name = features[1]
        leftEyeNode.rotation = SCNVector4(0, 1, 0, GLKMathDegreesToRadians(180.0))
        node.addChildNode(leftEyeNode)
        
        let rightEyeNode = EmojiNode(with: eyeOptions)
        rightEyeNode.name = features[2]
        node.addChildNode(rightEyeNode)
        
        let mouthNode = EmojiNode(with: mouthOptions)
        mouthNode.name = features[3]
        node.addChildNode(mouthNode)
        
        let hatNode = EmojiNode(with: hatOptions)
        hatNode.name = features[4]
        node.addChildNode(hatNode)
        
        updateFeatures(for: node, using: faceAnchor)
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor,
            let faceGeometry = node.geometry as? ARSCNFaceGeometry
        else { return }
        
        faceGeometry.update(from: faceAnchor.geometry)
        updateFeatures(for: node, using: faceAnchor)
    }
}
