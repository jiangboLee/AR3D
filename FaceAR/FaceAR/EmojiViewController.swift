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

}

extension EmojiViewController: ARSCNViewDelegate {
    
}
