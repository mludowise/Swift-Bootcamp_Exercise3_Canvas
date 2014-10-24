//
//  CanvasViewController.swift
//  Canvas
//
//  Created by Mel Ludowise on 10/23/14.
//  Copyright (c) 2014 Mel Ludowise. All rights reserved.
//

import UIKit

class CanvasViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var trayArrowImage: UIImageView!
    @IBOutlet weak var trayView: UIView!
    
    let kScreenHeight : CGFloat = UIScreen.mainScreen().bounds.height
    let kTrayOpenHeight : CGFloat = 205
    let kTrayClosedHeight : CGFloat = 46
    
    var closedTrayPosition : CGFloat = 0
    var openTrayPosition : CGFloat = 0
    
    var trayIsOpen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        closedTrayPosition = kScreenHeight - kTrayClosedHeight
        openTrayPosition = kScreenHeight - kTrayOpenHeight
        trayView.frame.origin.y = closedTrayPosition
        rotateArrow()
    }

    @IBAction func onTrayPan(sender: UIPanGestureRecognizer) {
//        if (sender.state == UIGestureRecognizerState.Began) {
//            
//        }
        
        var translation = sender.translationInView(view)
        var trayPosY = (trayIsOpen ? openTrayPosition : closedTrayPosition) + translation.y
        
        if (trayPosY < openTrayPosition) { // Frictional Drag
            trayView.frame.origin.y = openTrayPosition - (openTrayPosition - trayPosY) / 10
        } else if (trayPosY > closedTrayPosition) { // Bounce Closed
            trayView.frame.origin.y = closedTrayPosition + (trayPosY - closedTrayPosition) / 2
        } else {
            trayView.frame.origin.y = trayPosY
        }
        
        rotateArrow()
        
        if (sender.state == UIGestureRecognizerState.Ended) {
            if (sender.velocityInView(view).y < 0) {
                openTray()
            } else {
                closeTray()
            }
        }
    }
    
    private func closeTray() {
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.trayView.frame.origin.y = self.closedTrayPosition
            self.rotateArrow()
            }) { (b: Bool) -> Void in
                self.trayIsOpen = false
        }
    }
    
    private func openTray() {
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.trayView.frame.origin.y = self.openTrayPosition
            self.rotateArrow()
            }) { (b: Bool) -> Void in
                self.trayIsOpen = true
        }
    }
    
    private func rotateArrow() {
        var trayPos = trayView.frame.origin.y
        var rotation = (trayPos - openTrayPosition) / (closedTrayPosition - openTrayPosition)
        //        rotation = min(1, rotation)
        //        rotation = max(0, rotation)
        trayArrowImage.transform = CGAffineTransformMakeRotation(rotation * CGFloat(M_PI))
    }
    
    var currentFace : UIImageView?
    var initialFaceTransform : CGAffineTransform?
    
    @IBAction func onFaceTrayPan(sender: UIPanGestureRecognizer) {
        var face = sender.view as UIImageView
        if (currentFace == nil) {
            currentFace = addFaceToCanvas(face)
        }
        var position = sender.locationInView(view)
        moveFace(currentFace!, position: position)
        if (sender.state == UIGestureRecognizerState.Ended) {
            currentFace = nil
        }
    }
    
    var trayIsTemporarilyOpened = false
    
    func onFacePan(sender: UIPanGestureRecognizer) {
        var face = sender.view as Face
        var position = sender.locationInView(view)
        
        moveFace(face, position: position)
        
        if (!trayIsOpen && position.y > closedTrayPosition) {
            openTray()
            trayIsTemporarilyOpened = true
        }
        if (trayIsTemporarilyOpened && position.y < openTrayPosition) {
            closeTray()
        }
        
        if (sender.state == UIGestureRecognizerState.Ended) {
            if (position.y > openTrayPosition) { // Dragged onto open tray
                deleteFace(face, onCompletion: { () -> Void in
                    if (self.trayIsTemporarilyOpened) {
                        self.closeTray()
                    }
                })
            }
        }
    }
    
    private func moveFace(face: UIImageView, position: CGPoint) {
        face.center = position
    }
    
    func onFacePinch(sender: UIPinchGestureRecognizer) {
        var face = sender.view as UIImageView
        var scale = sender.scale
        
        if (sender.state == UIGestureRecognizerState.Began) {
            initialFaceTransform = face.transform
        }
        
        face.transform = CGAffineTransformScale(initialFaceTransform!, scale, scale)
    }
    
    func onFaceRotate(sender: UIRotationGestureRecognizer) {
        var face = sender.view as UIImageView
        var rotation = sender.rotation
        
        if (sender.state == UIGestureRecognizerState.Began) {
            initialFaceTransform = face.transform
        }
        
        face.transform = CGAffineTransformRotate(initialFaceTransform!, rotation)
    }
    
    private func addFaceToCanvas(face: UIImageView) -> UIImageView {
        var newFace = Face(originalFace: face)
        newFace.frame = face.frame
        newFace.userInteractionEnabled = true
        view.addSubview(newFace)
        
        var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "onFacePan:")
        panGestureRecognizer.delegate = self
        newFace.addGestureRecognizer(panGestureRecognizer)
        
        var pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "onFacePinch:")
        pinchGestureRecognizer.delegate = self
        newFace.addGestureRecognizer(pinchGestureRecognizer)
        
        var rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: "onFaceRotate:")
        rotationGestureRecognizer.delegate = self
        newFace.addGestureRecognizer(rotationGestureRecognizer)
        
        return newFace
    }
    
    private func deleteFace(face: Face, onCompletion: (() -> Void)?) {
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            face.center = self.view.convertPoint(face.originalFace.center, fromView: self.trayView)
            face.transform = CGAffineTransformIdentity
            }) { (b: Bool) -> Void in
                face.removeFromSuperview()
                if (onCompletion != nil) {
                    onCompletion!()
                }
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool {
        return true
    }
}

private class Face : UIImageView {
    var originalFace : UIImageView
    
    init(originalFace: UIImageView) {
        self.originalFace = originalFace
        super.init(image: originalFace.image)
        self.frame = originalFace.frame
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}