//
//  ViewController.swift
//  ImagePlay
//
//  Created by LEE on 2018/9/20.
//  Copyright © 2018年 LEE. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    static let oneVideo = Bundle.main.url(forResource: "1", withExtension: "MP4")!
    static let twoVideo = Bundle.main.url(forResource: "2", withExtension: "MP4")!
    let players = ["1": AVPlayer(url: oneVideo), "2": AVPlayer(url: twoVideo)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        for (_, player) in players {
            videoObserver(for: player)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupImageTrackingConfiguration()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func setupImageTrackingConfiguration() {
        let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "me", bundle: Bundle.main)!
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = referenceImages
        configuration.maximumNumberOfTrackedImages = 2
        sceneView.session.run(configuration)
    }
    
    func videoObserver(for videoPlayer: AVPlayer) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { (notification) in
            videoPlayer.seek(to: CMTime.zero)
        }
    }
    

    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        if let imageAnchor = anchor as? ARImageAnchor {
            let player = players[imageAnchor.name!]!
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            plane.firstMaterial?.diffuse.contents = player
            player.seek(to: CMTime.zero)
            player.play()
            
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = Float(-Double.pi * 0.5)
            node.addChildNode(planeNode)
        }
        return node
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        if let pointOfView = sceneView.pointOfView {
            let isVisible = sceneView.isNode(node, insideFrustumOf: pointOfView)
            if isVisible {
                let player = players[imageAnchor.name!]!
                if player.rate == 0 {
                    player.play()
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
