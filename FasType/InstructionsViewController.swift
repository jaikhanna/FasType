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
import JTFadingInfoView
import Material

class InstructionsViewController: UIViewController, MCBrowserViewControllerDelegate{
    
    var appDelegate:AppDelegate!
    
    
    @IBOutlet weak var PlayNow: FabButton!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.mpcHandler.setupPeerWithDisplayName(UIDevice.currentDevice().name)
        appDelegate.mpcHandler.setupSession()
        appDelegate.mpcHandler.advertiseSelf(true)
        
    }
    
    @IBAction func connectWithPlayer(sender: AnyObject) {
        if appDelegate.mpcHandler.session != nil{
            appDelegate.mpcHandler.setupBrowser()
            appDelegate.mpcHandler.browser.delegate = self
            
            self.presentViewController(appDelegate.mpcHandler.browser, animated: true, completion: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if segue.identifier == "toQuestion"{
            
            //loading sign
            loadingIndicator.startAnimating()
            
            let tq = segue.destinationViewController as! QuestionViewController
            tq.appDelegate = appDelegate
        }
    }
    
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController) {
        appDelegate.mpcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController) {
         appDelegate.mpcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }
    
}