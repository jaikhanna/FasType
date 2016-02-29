//
//  InstructionsViewController.swift
//  FasType
//
//  Created by Jai Khanna on 11/15/15.
//  Copyright © 2015 Jai Khanna. All rights reserved.
//

//import Foundation
import UIKit
import MultipeerConnectivity

class InstructionsViewController: UIViewController, MCBrowserViewControllerDelegate{
    
    var appDelegate:AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.mpcHandler.setupPeerWithDisplayName(UIDevice.currentDevice().name)
        appDelegate.mpcHandler.setupSession()
        appDelegate.mpcHandler.advertiseSelf(true)
//
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peerChangedStateWithNotification:", name: "MPC_DidChangeStateNotification", object: nil)
//        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleReceivedDataWithNotification:", name: "MPC_DidReceiveDataNotification", object: nil)
        
    }
    
    @IBAction func connectWithPlayer(sender: AnyObject) {
        if appDelegate.mpcHandler.session != nil{
            appDelegate.mpcHandler.setupBrowser()
            appDelegate.mpcHandler.browser.delegate = self
            
            self.presentViewController(appDelegate.mpcHandler.browser, animated: true, completion: nil)
        }
    }
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController) {
        appDelegate.mpcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController) {
         appDelegate.mpcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }
    
}



