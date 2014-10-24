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
    
    var closedTrayPosition : CGFloat = 0
    var openTrayPosition : CGFloat = 0
    
    var trayShown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var screenSize = UIScreen.mainScreen().bounds.size
        closedTrayPosition = trayView.frame.origin.y
        openTrayPosition = screenSize.height - trayView.frame.size.height
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
        } else {
            trayView.frame.origin.y = min(closedTrayPosition, trayPosY)
        }
        
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
            }) { (b: Bool) -> Void in
                self.trayShown = false
        }
    }
    
    private func openTray() {
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.trayView.frame.origin.y = self.openTrayPosition
            }) { (b: Bool) -> Void in
                self.trayShown = true
        }
    }
}
