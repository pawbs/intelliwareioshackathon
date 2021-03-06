/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller for the AR experience.
*/

import UIKit
import SceneKit
import ARKit
import MultipeerConnectivity

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    // MARK: - IBOutlets
    
    @IBOutlet weak var sessionInfoView: UIView!
    @IBOutlet weak var sessionInfoLabel: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var sendMapButton: UIButton!
    @IBOutlet weak var mappingStatusLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var goodBadTryControl: UISegmentedControl!
    @IBOutlet weak var bottomContraint: NSLayoutConstraint!
    
    // MARK: - View Life Cycle
    
    var multipeerSession: MultipeerSession!
    var initialConstant:CGFloat!
    
    fileprivate func showDoneToolbarOnKeyboard() {
        let doneBar = UIToolbar()
        doneBar.sizeToFit()
        let doneButton = UIBarButtonItem.init(title: "Done", style: .plain, target: self, action: #selector(doneFromKeyboardClicked(_ :)))
        let spacer = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        doneBar.setItems([spacer, doneButton], animated: false)
        self.inputTextField.inputAccessoryView = doneBar
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        multipeerSession = MultipeerSession(receivedDataHandler: receivedData)
        showDoneToolbarOnKeyboard()
        self.initialConstant = self.bottomContraint.constant;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardShow(_:)), name:UIResponder.keyboardWillShowNotification, object:nil);
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillHide(_:)), name:UIResponder.keyboardWillHideNotification, object:nil);
    }

    @objc func keyboardShow(_ notification:NSNotification) {
    
        let keyboardSize = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue;
        
        if (self.bottomContraint.constant == 0 || keyboardSize.cgRectValue.height > self.bottomContraint.constant) {
            UIView.animate(withDuration:2, animations: {
                            self.bottomContraint.constant = keyboardSize.cgRectValue.height
                            self.view.layoutIfNeeded()  })
        }
    }

    @objc func keyboardWillHide(_ notification:NSNotification) {
        
        UIView.animate(withDuration:2, animations: {
            self.bottomContraint.constant = self.initialConstant
            self.view.layoutIfNeeded()
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard ARWorldTrackingConfiguration.isSupported else {
            fatalError("""
                ARKit is not available on this device. For apps that require ARKit
                for core functionality, use the `arkit` key in the key in the
                `UIRequiredDeviceCapabilities` section of the Info.plist to prevent
                the app from installing. (If the app can't be installed, this error
                can't be triggered in a production scenario.)
                In apps where AR is an additive feature, use `isSupported` to
                determine whether to show UI for launching AR experiences.
            """) // For details, see https://developer.apple.com/documentation/arkit
        }
        
        // Start the view's AR session.
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        
        // Set a delegate to track the number of plane anchors for providing UI feedback.
        sceneView.session.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        // Prevent the screen from being dimmed after a while as users will likely
        // have long periods of interaction without touching the screen or buttons.
        UIApplication.shared.isIdleTimerDisabled = true
        
    }
    
    @objc func doneFromKeyboardClicked(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's AR session.
        sceneView.session.pause()

        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if let name = anchor.name, name.hasPrefix("card") {
            var color: UIColor
            var type:String
            let iColor = name.index(name.startIndex, offsetBy: 4)

            print(name[iColor])
            if (name[iColor] == "0") {
                // Blue
                color = UIColor.init(red: 155.0/255.0, green: 192.0/255.0, blue: 226.0/255.0, alpha: 1)
                type = Card.types[0]
                
            } else if (name[iColor] == "1") {
                // Red
                color = UIColor.init(red: 249.0/255.0, green: 123.0/255.0, blue: 118.0/255.0, alpha: 1)
                type = Card.types[1]
            } else {
                // Gold
                color = UIColor.init(red: 243.0/255.0, green: 207.0/255.0, blue: 98.0/255.0, alpha: 1)
                type = Card.types[2]

            }
                        
            node.addChildNode(loadRedPandaModel())
            node.addChildNode(createBoxNode(color: color))
            node.addChildNode(createTextNode(string: String(name.dropFirst(5))))
            
            let card = Card(text: String(name.dropFirst(5)), type: type)
            CardDeck.instance.cards.append(card)
        }
    }
    
    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }
    
    /// - Tag: CheckMappingStatus
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        switch frame.worldMappingStatus {
        case .notAvailable, .limited:
            sendMapButton.isEnabled = false
        case .extending:
            sendMapButton.isEnabled = !multipeerSession.connectedPeers.isEmpty
        case .mapped:
            sendMapButton.isEnabled = !multipeerSession.connectedPeers.isEmpty
        }
        mappingStatusLabel.text = frame.worldMappingStatus.description
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    // MARK: - ARSessionObserver
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay.
        sessionInfoLabel.text = "Session was interrupted"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required.
        sessionInfoLabel.text = "Session interruption ended"
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user.
        sessionInfoLabel.text = "Session failed: \(error.localizedDescription)"
        resetTracking(nil)
    }
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }
    
    // MARK: - Multiuser shared session
    
    /// - Tag: PlaceCharacter
    @IBAction func handleSceneTap(_ sender: UITapGestureRecognizer) {
        
        // Hit test to find a place for a virtual object.
        guard let hitTestResult = sceneView
            .hitTest(sender.location(in: sceneView), types: [.existingPlaneUsingGeometry, .estimatedHorizontalPlane])
            .first
            else { return }
        
        // Place an anchor for a virtual character. The model appears in renderer(_:didAdd:for:).
        
        var anchorName: String
        //        anchor.setValue(inputTextField.text!, forKey: "text")
        //        anchor.setValue(goodBadTryControl.selectedSegmentIndex, forKey: "color")
        anchorName = "card" + String(goodBadTryControl.selectedSegmentIndex) + inputTextField.text!
        let anchor = ARAnchor(name: anchorName, transform: hitTestResult.worldTransform)

//        let card = Card(text: self.inputTextField.text!, type:Card.types[self.goodBadTryControl.selectedSegmentIndex]);
//        CardDeck.instance.cards .append(card);
        
        sceneView.session.add(anchor: anchor)
        
        // Send the anchor info to peers, so they can place the same content.
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: true)
            else { fatalError("can't encode anchor") }
        self.multipeerSession.sendToAllPeers(data)

//        do {
//            let cardData = try JSONEncoder().encode(card)
//            self.multipeerSession.sendToAllPeers(cardData)
//        } catch {
//            print(error)
//        }
    }
    
    /// - Tag: GetWorldMap
    @IBAction func shareSession(_ button: UIButton) {
        sceneView.session.getCurrentWorldMap { worldMap, error in
            guard let map = worldMap
                else { print("Error: \(error!.localizedDescription)"); return }
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                else { fatalError("can't encode map") }
            self.multipeerSession.sendToAllPeers(data)
        }
    }
    
    var mapProvider: MCPeerID?

    /// - Tag: ReceiveData
    func receivedData(_ data: Data, from peer: MCPeerID) {
        
        print("number of bytes of data: \(data.count)")
        do {
            if let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) {
                print("worldMap received")
                
                // Run the session with the received world map.
                let configuration = ARWorldTrackingConfiguration()
                configuration.planeDetection = .horizontal
                configuration.initialWorldMap = worldMap
                sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
                
                // Remember who provided the map for showing UI feedback.
                mapProvider = peer
            }
            else
            if let anchor = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARAnchor.self, from: data) {
                print("anchor received")
                // Add anchor to the session, ARSCNView delegate adds visible content.
                sceneView.session.add(anchor: anchor)
            } else {
                print("error: not found")
            }
        } catch {
            print("can't decode data recieved from \(peer)")
        }
    }
    
    // MARK: - AR session management
    
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        let message: String
        
        switch trackingState {
        case .normal where frame.anchors.isEmpty && multipeerSession.connectedPeers.isEmpty:
            // No planes detected; provide instructions for this app's AR interactions.
            message = "Move around to map the environment, or wait to join a shared session."
            
        case .normal where !multipeerSession.connectedPeers.isEmpty && mapProvider == nil:
            let peerNames = multipeerSession.connectedPeers.map({ $0.displayName }).joined(separator: ", ")
            message = "Connected with \(peerNames)."
            
        case .notAvailable:
            message = "Tracking unavailable."
            
        case .limited(.excessiveMotion):
            message = "Tracking limited - Move the device more slowly."
            
        case .limited(.insufficientFeatures):
            message = "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."
            
        case .limited(.initializing) where mapProvider != nil,
             .limited(.relocalizing) where mapProvider != nil:
            message = "Received map from \(mapProvider!.displayName)."
            
        case .limited(.relocalizing):
            message = "Resuming session — move to where you were when the session was interrupted."
            
        case .limited(.initializing):
            message = "Initializing AR session."
            
        default:
            // No feedback needed when tracking is normal and planes are visible.
            // (Nor when in unreachable limited-tracking states.)
            message = ""
            
        }
        
        sessionInfoLabel.text = message
        sessionInfoView.isHidden = message.isEmpty
    }
    
    @IBAction func resetTracking(_ sender: UIButton?) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    // MARK: - AR session management
    private func loadRedPandaModel() -> SCNNode {
        let sceneURL = Bundle.main.url(forResource: "max", withExtension: "scn", subdirectory: "Assets.scnassets")!
        
        let referenceNode = SCNReferenceNode(url: sceneURL)!
        referenceNode.load()
    
        return referenceNode
    }
    
    private func createTextNode(string: String) -> SCNNode {
        let text = SCNText(string: string, extrusionDepth: 0.05)
        text.font = UIFont.systemFont(ofSize: 1)
        text.flatness = 0.01
        
        text.containerFrame = CGRect(x: 0, y: 0.5, width: 4, height: 5)
        text.isWrapped = true
        
        let textNode = SCNNode(geometry: text)
        
        let fontSize = Float(0.02)
        textNode.scale = SCNVector3(fontSize, fontSize, fontSize)
        textNode.position = SCNVector3(-0.04, 0, 0.1);
        textNode.eulerAngles = SCNVector3(-1, 0, 0);
        
        return textNode
    }
    
    private func createBoxNode(color: UIColor) -> SCNNode {
        let box = SCNBox(width: 0.1, height: 0.01, length: 0.1, chamferRadius: 0.01)
        box.firstMaterial?.diffuse.contents = color
        box.firstMaterial?.diffuse.textureComponents = SCNColorMask()
        
        let boxNode = SCNNode(geometry: box)
        return boxNode
    }
    
}

