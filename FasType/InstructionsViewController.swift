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
        
        
        
        //testing data transfer
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
    
    
    //testing sendData
//    func peerChangedStateWithNotification(notification:NSNotification){
//        let userInfo = NSDictionary(dictionary: notification.userInfo!)
//        
//        let state = userInfo.objectForKey("state") as! Int
//        
//        if state != MCSessionState.Connecting.rawValue{
//            self.navigationItem.title = "Connected"
//            //send score to all connected players/peers
//            let messageDict = ["score":Int(40)]
//            
//            do{
//                let messageData = try? NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted)
//                
//                try appDelegate.mpcHandler.session.sendData(messageData!, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
//                
//                print(messageData!)
//            }catch let error as NSError {
//                print("An error occurred: \(error)")
//            }
//        }
//        
//    }
    
    //testing receipt of data
//    func handleReceivedDataWithNotification(notification:NSNotification){
//        
//        print("This confirms data receipt in InstructionsView")
//        
//        
//    }
    
    //testing the 'segue' method of making this work!
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject!) -> Bool {
//        if identifier == "toQuestion" {
//           return true
//        }
//        
        // by default, transition
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if segue.identifier == "toQuestion"{
            
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



