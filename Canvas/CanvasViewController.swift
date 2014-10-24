//
//  CanvasViewController.swift
//  Canvas
//
//  Created by Mel Ludowise on 10/23/14.
//  Copyright (c) 2014 Mel Ludowise. All rights reserved.
//

import UIKit

class CanvasViewController: UIViewController {
    
    @IBOutlet weak var trayArrowImage: UIImageView!
    @IBOutlet weak var trayView: UIView!
    
    let kScreenHeight : CGFloat = UIScreen.mainScreen().bounds.height
    let kTrayOpenHeight : CGFloat = 205
    let kTrayClosedHeight : CGFloat = 46
    
    var closedTrayPosition : CGFloat = 0
    var openTrayPosition : CGFloat = 0
    
    var trayShown = false
    
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
        
        println("pan")
        
        var translation = sender.translationInView(view)
        
        var trayPosY = (trayShown ? openTrayPosition : closedTrayPosition) + translation.y
        
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
                self.trayShown = false
        }
    }
    
    private func openTray() {
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.trayView.frame.origin.y = self.openTrayPosition
            self.rotateArrow()
            }) { (b: Bool) -> Void in
                self.trayShown = true
        }
    }
    
    private func rotateArrow() {
        var trayPos = trayView.frame.origin.y
        var rotation = (trayPos - openTrayPosition) / (closedTrayPosition - openTrayPosition)
//        rotation = min(1, rotation)
//        rotation = max(0, rotation)
        trayArrowImage.transform = CGAffineTransformMakeRotation(rotation * CGFloat(M_PI))
    }
}
