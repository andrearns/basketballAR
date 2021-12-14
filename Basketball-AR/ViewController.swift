//
//  ViewController.swift
//  Basketball-AR
//
//  Created by André Arns on 10/11/21.
//

import UIKit
import SceneKit
import ARKit
import CoreMotion

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {
    
    let motionManager: CMMotionManager = {
       let result = CMMotionManager()
        result.accelerometerUpdateInterval = 1/30
        return result
    }()

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
        
        self.sceneView.scene.physicsWorld.contactDelegate = self
    }

    var balls = [String]()
    var contactedBalls = [String: Int]()
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        if let name = contact.nodeB.name {
            contactedBalls[name] = (contactedBalls[name] ?? 0) + 1
            if ((contactedBalls[name] ?? 0) == 8) {
                print("PONTO")
            }
        }
    }
    
    func addBackboard() {
        guard let backboardScene = SCNScene(named: "art.scnassets/hoop.scn") else {
            return
        }
        
        guard let backboardNode = backboardScene.rootNode.childNode(withName: "backboard", recursively: false), let netNode = backboardScene.rootNode.childNode(withName: "net", recursively: false), let sensorNode = backboardScene.rootNode.childNode(withName: "score", recursively: false) else {
            return
        }
        
        backboardNode.position = SCNVector3(x: 0, y: 0.75, z: -5)
        sensorNode.position = SCNVector3(x: 0.042, y: 0.945, z: -4.385)
        netNode.position = SCNVector3(x: -0.022, y: 0.75, z: -5.02)
        
        let physicsShape = SCNPhysicsShape(node: backboardNode, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron])
        let physicsBody = SCNPhysicsBody(type: .static, shape: physicsShape)
        
        backboardNode.physicsBody = physicsBody
        
        sceneView.scene.rootNode.addChildNode(backboardNode)
        
        sensorNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: sensorNode))
        sensorNode.physicsBody?.categoryBitMask = 8
        sensorNode.physicsBody?.collisionBitMask = 0
        
        sceneView.scene.rootNode.addChildNode(sensorNode)
        sceneView.scene.rootNode.addChildNode(netNode)

        
        motionManager.startAccelerometerUpdates(to: .main) { data, error in
            self.handleShake(data, error)
        }
    }
    
    var lastBall = Date()
    
    func handleShake(_ data: CMAccelerometerData?, _ error: Error?) {
        guard error == nil, let a = data?.acceleration.z else { return }
        let acc = abs(a)
        if acc >= 2 && lastBall.advanced(by: 0.2).compare(Date()) == .orderedAscending {
            lastBall = Date()
            
            guard let centerPoint = sceneView.pointOfView else { return }
            
            let cameraTransform = centerPoint.transform
            let cameraLocation = SCNVector3(x: cameraTransform.m41, y: cameraTransform.m42, z: cameraTransform.m43)
            let cameraOrientation = SCNVector3(x: -cameraTransform.m31, y: -cameraTransform.m32, z: -cameraTransform.m33)
            
            let cameraPosition = SCNVector3Make(cameraLocation.x + cameraOrientation.x, cameraLocation.y + cameraOrientation.y, cameraLocation.z + cameraOrientation.z)
            
            let ball = SCNSphere(radius: 0.15)
            let ballMaterial = SCNMaterial()
            ballMaterial.diffuse.contents = UIImage(named: "basketballSkin.png")
            ball.materials = [ballMaterial]
            
            let ballNode = SCNNode(geometry: ball)
            ballNode.position = cameraPosition
            ballNode.name = UUID().uuidString
            
            balls.append(ballNode.name!)
            
            let physicsShape = SCNPhysicsShape(node: ballNode, options: nil)
            let physicsBody = SCNPhysicsBody(type: .dynamic, shape: physicsShape)
            
            physicsBody.contactTestBitMask = 8
            ballNode.physicsBody = physicsBody
            
            
            let forceVector: Float = 3
            ballNode.physicsBody?.applyForce(
                SCNVector3(
                    x: cameraOrientation.x * forceVector,
                    y: cameraOrientation.y * Float(abs(acc)) * forceVector,
                    z: cameraOrientation.z * Float(abs(acc)) * forceVector
                ),
                asImpulse: true
            )

            sceneView.scene.rootNode.addChildNode(ballNode)
        }
    }
    
    func horizontalAction(node: SCNNode) {
        let leftAction = SCNAction.move(by: SCNVector3(x: -1, y: 0, z: 0), duration: 2)
        let rightAction = SCNAction.move(by: SCNVector3(x: 1, y: 0, z: 0), duration: 2)
        
        let actionSequence = SCNAction.sequence([leftAction, rightAction])
        node.runAction(SCNAction.repeatForever(actionSequence))
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
