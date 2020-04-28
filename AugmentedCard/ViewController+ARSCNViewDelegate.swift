import UIKit
import SceneKit
import ARKit

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        
        let referenceImage = imageAnchor.referenceImage
        
        updateQueue.async {
            let physicalWidth = imageAnchor.referenceImage.physicalSize.width
            let physicalHeight = imageAnchor.referenceImage.physicalSize.height
            
            // Create a plane geometry to visualize the initial position of the detected image
            let mainPlane = SCNPlane(width: physicalWidth, height: physicalHeight)
            mainPlane.firstMaterial?.colorBufferWriteMask = .alpha
            
            // Create a SceneKit root node with the plane geometry to attach to the scene graph
            // This node will hold the virtual UI in place
            let mainNode = SCNNode(geometry: mainPlane)
            mainNode.eulerAngles.x = -.pi / 2
            mainNode.renderingOrder = -1
            mainNode.opacity = 1
            
            // Add the plane visualization to the scene
            node.addChildNode(mainNode)
            
            // Perform a quick animation to visualize the plane on which the image was detected.
            // We want to let our users know that the app is responding to the tracked image.
            self.highlightDetection(on: mainNode, width: physicalWidth, height: physicalHeight, completionHandler: {
                
                // Introduce virtual content
                self.displayDetailView(on: mainNode, xOffset: physicalWidth, im: referenceImage)
                
                // Animate the WebView to the right
                self.displayWebView(on: mainNode, xOffset: physicalWidth, im: referenceImage)
                
            })
        }
    }
    
    func displayDetailView(on rootNode: SCNNode, xOffset: CGFloat, im: ARReferenceImage) {
        if (im.name == "Benny") {
            let detailPlane = SCNPlane(width: xOffset, height: xOffset/2)
            detailPlane.cornerRadius = 0.15
            
            let detailNode = SCNNode(geometry: detailPlane)
            detailNode.geometry?.firstMaterial?.diffuse.contents = SKScene(fileNamed: "name")
            
            // Due to the origin of the iOS coordinate system, SCNMaterial's content appears upside down, so flip the y-axis.
            detailNode.geometry?.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
            detailNode.position.z -= 0.5
            detailNode.opacity = 0
            
            rootNode.addChildNode(detailNode)
            detailNode.runAction(.sequence([
                .wait(duration: 0.3),
                .fadeOpacity(to: 0.5, duration: 1.0),
                .moveBy(x: 0, y: xOffset * 0.75, z: -0.05, duration: 1.0),
                .moveBy(x: 0, y: 0, z: 0.5, duration: 0.2)
                ])
            )
            
            let detailPlane2 = SCNPlane(width: xOffset, height: xOffset / 4)
            detailPlane2.cornerRadius = 0.15
            
            let detailNode2 = SCNNode(geometry: detailPlane2)
            detailNode2.geometry?.firstMaterial?.diffuse.contents = SKScene(fileNamed: "social")
            
            
            // Due to the origin of the iOS coordinate system, SCNMaterial's content appears upside down, so flip the y-axis.
            detailNode2.geometry?.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
            detailNode2.position.z -= 0.5
            detailNode2.opacity = 0
            
            rootNode.addChildNode(detailNode2)
            detailNode2.runAction(.sequence([
                .wait(duration: 2.2),
                .fadeOpacity(to: 1.0, duration: 1.5),
                .moveBy(x: 0, y: xOffset * 0.5, z: -0.05, duration: 1.0),
                .moveBy(x: 0, y: 0, z: 0.5, duration: 0.2)
                ])
            )
            
            let detailPlane3 = SCNPlane(width: xOffset, height: xOffset)
                    detailPlane3.cornerRadius = 0.15
            
            let detailNode3 = SCNNode(geometry: detailPlane3)
            detailNode3.geometry?.firstMaterial?.diffuse.contents = SKScene(fileNamed: "citrus")
            
            // Due to the origin of the iOS coordinate system, SCNMaterial's content appears upside down, so flip the y-axis.
            detailNode3.geometry?.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
            detailNode3.position.z -= 0.5
            detailNode3.opacity = 0
            
            rootNode.addChildNode(detailNode3)
            detailNode3.runAction(.sequence([
                .wait(duration: 6.8),
                .fadeOpacity(to: 1.0, duration: 1.5),
                .moveBy(x: 0, y: xOffset * -0.9, z: -0.05, duration: 1.5),
                .moveBy(x: 0, y: 0, z: 0.5, duration: 0.2)
                ])
            )
        }
    }
    
    func displayWebView(on rootNode: SCNNode, xOffset: CGFloat, im: ARReferenceImage) {
        // Xcode yells at us about the deprecation of UIWebView in iOS 12.0, but there is currently
        // a bug that does now allow us to use a WKWebView as a texture for our webViewNode
        // Note that UIWebViews should only be instantiated on the main thread!
        DispatchQueue.main.async {
            let request = URLRequest(url: URL(string: "https://www.citrushack.com/")!)
            let webView = UIWebView(frame: CGRect(x: 0, y: 0, width: 700, height: 700))
            webView.loadRequest(request)
            
            let webViewPlane = SCNPlane(width: xOffset * 2.0, height: xOffset * 2.3)
            webViewPlane.cornerRadius = 0.25
            
            let webViewNode = SCNNode(geometry: webViewPlane)
            webViewNode.geometry?.firstMaterial?.diffuse.contents = webView
            webViewNode.position.z -= 0.5
            webViewNode.opacity = 0
            
            rootNode.addChildNode(webViewNode)
            webViewNode.runAction(.sequence([
                .wait(duration: 11.0),
                .fadeOpacity(to: 1.0, duration: 1.5),
                .moveBy(x: xOffset * 1.6, y: xOffset * -0.22, z: 0, duration: 1.5),
                .moveBy(x: 0, y: 0, z: 0.5, duration: 0.2)
                ])
            )
        }
    }
    
    func highlightDetection(on rootNode: SCNNode, width: CGFloat, height: CGFloat, completionHandler block: @escaping (() -> Void)) {
        let planeNode = SCNNode(geometry: SCNPlane(width: width, height: height))
        planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        planeNode.position.z += 0.1
        planeNode.opacity = 0
        
        rootNode.addChildNode(planeNode)
        planeNode.runAction(self.imageHighlightAction) {
            block()
        }
    }
    
    var imageHighlightAction: SCNAction {
        return .sequence([
            .wait(duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOpacity(to: 0.15, duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOut(duration: 0.5),
            .removeFromParentNode()
            ])
    }
    
}
