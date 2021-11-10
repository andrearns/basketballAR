//
//  ViewController.swift
//  Basketball-AR
//
//  Created by André Arns on 10/11/21.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        addBackboard()
        registerGestureRecognizer()
    }
    
    func registerGestureRecognizer() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipe.direction = .up
        sceneView.addGestureRecognizer(swipe)
    }
    
    @objc
    func handleSwipe(gestureRecognizer: UIGestureRecognizer) {
        // Scene view to be accessed
        guard let sceneView = gestureRecognizer.view as? ARSCNView else {
            return
        }
        
        // Access the point of view of the scene view
        guard let centerPoint = sceneView.pointOfView else {
            return
        }
        
        // Transform matrix
        // Orientation
        // Location of the camera
        
        
    }
    
    func addBackboard() {
        guard let backboardScene = SCNScene(named: "art.scnassets/hoop.scn") else {
            return
        }
        
        guard let backboardNode = backboardScene.rootNode.childNode(withName: "backboard", recursively: false) else {
            return
        }
        
        backboardNode.position = SCNVector3(x: 0, y: 0.5, z: -3)
        
        sceneView.scene.rootNode.addChildNode(backboardNode)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
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
