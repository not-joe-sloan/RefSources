//
//  CircleTransitionAnimator.swift
//  CircleTransition
//
//  Created by Rounak Jain on 23/10/14.
//  Copyright (c) 2014 Rounak Jain. All rights reserved.
//

import UIKit

class CircleTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  
  weak var transitionContext: UIViewControllerContextTransitioning?
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.5;
  }
  
  //This function does the actual animating
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    
              //Define a transitionContext variable
              self.transitionContext = transitionContext
    
              //Set up a container for transition
              let containerView = transitionContext.containerView
    
              //Define the transitioning viewController
              let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! ViewController
    
              //Define the target viewController
              let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! ViewController
    
              //Define the button as whichever one is used in the transitioning viewController.
              let button: UIButton = fromViewController.button
    
              // Add the target view controller to the view
              containerView.addSubview(toViewController.view)
    
              // Draw initial and final bezier paths
              let circleMaskPathInitial = UIBezierPath(ovalIn: button.frame)
    
              //Set an extreme point guaranteed to be outside the view's bounds, to draw the outer circle
              let extremePoint = CGPoint(x: button.center.x - 0, y: button.center.y - toViewController.view.bounds.height)
    
              //Define a radius expansion measurement for the final bezier path
              let radius = sqrt((extremePoint.x * extremePoint.x) + (extremePoint.y * extremePoint.y))
    
              //define the final circleMaskPath as the the initialPath inset by the inverse of the radius variable.
              let circleMaskPathFinal = UIBezierPath(ovalIn: button.frame.insetBy(dx: -radius, dy: -radius))
    
              //define a CAShapeLayer
              let maskLayer = CAShapeLayer()
    
              //define the shape of the path with circleMaskPathFinal
              maskLayer.path = circleMaskPathFinal.cgPath
    
              //create a layer on top of the initialViewController, that's basically masked into a tiny circle by the maskLayer object.
              toViewController.view.layer.mask = maskLayer
    
              //let's get this bitch going
              CATransaction.begin()
    
              //Create a basic animation, and set its identifier to "path"
              let maskLayerAnimation = CABasicAnimation(keyPath: "path")
    
              //Set the fromValue (first state) of the CABasicAnimation to our initial path, the size of the button.
              maskLayerAnimation.fromValue = circleMaskPathInitial.cgPath
    
              //Set the toValue (second state) of the CABasicAnimation to our initial path, the size of the extremePoint circle.
              maskLayerAnimation.toValue = circleMaskPathFinal.cgPath
    
              //Set the duration of the animation to the value defined clear up at the top, under [func transitionDuration(using transitionContext:)]
              maskLayerAnimation.duration = self.transitionDuration(using: transitionContext)
    
              //set the delegate of the CABasicAnimation object to the viewController, as some sort of animation controller script.
              maskLayerAnimation.delegate = self as? CAAnimationDelegate
    
              //Set up what to do when the animation completes.
              CATransaction.setCompletionBlock {
                
                //calls the completeTransition method, which essentially runs if the value inside () is true. Inside that, there's a check to see if the transition was somehow cancelled.  If it wasn't, that value returns true, which causes the completeTransition method to run.
                self.transitionContext?.completeTransition(!self.transitionContext!.transitionWasCancelled)
                
                //within the transitionContext, determine which viewController we are exiting, and remove any sort of masking from the view.
                self.transitionContext?.viewController(forKey: UITransitionContextViewControllerKey.from)?.view.layer.mask = nil
    }
    
    //Add the animation identified as "path", which we just spent all that time defining in the closures above.
    maskLayer.add(maskLayerAnimation, forKey: "path")
    
    //Finally, actually commit the segue, perform the animation, and chill till the next time this is needed.
    CATransaction.commit()
  }
}
