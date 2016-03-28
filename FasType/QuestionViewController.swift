//
//  QuestionViewController.swift
//  FasType
//
//  Created by Jai Khanna on 11/14/15.
//  Copyright © 2015 Jai Khanna. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class QuestionViewController: UIViewController {
    
    
    
    var sentences = ["hello world", "HackSC", "Two Sigma","bonjour", "Apple", "Microsoft","pranshu"]
    
    @IBOutlet weak var questionString: UILabel!
    @IBOutlet weak var userInput: UITextField!
    

    @IBOutlet weak var countingLabel: UILabel!
    
    var timer = NSTimer()
    var counter = 0
    var appDelegate:AppDelegate!
    var randomQuestionSentence: String = ""
    
    @IBAction func submitResponse(sender: UIButton) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add notification observer
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleReceivedDataWithNotification:", name: "MPC_DidReceiveDataNotification", object: nil)

        // Do any additional setup after loading the view, typically from a nib.
        [userInput .becomeFirstResponder()]
        
        //Timer UI
        countingLabel.layer.borderWidth = 5.0
        countingLabel.layer.borderColor = UIColor.magentaColor().CGColor
        countingLabel.layer.cornerRadius = 50
        
        
        //questionString UI
        questionString.layer.borderWidth = 2.0
        questionString.layer.borderColor = UIColor.magentaColor().CGColor
        questionString.layer.cornerRadius = 8
        questionString.layer.masksToBounds = true

        
//        userInput.returnKeyType = UIReturnKeyType.Go
        
        countingLabel.text = String(counter)
        

        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateCounter"), userInfo: nil, repeats: true)
        
//        self.navigationItem.setHidesBackButton(true, animated:true);
//        var randomIndex = Int(arc4random_uniform(UInt32(sentences.count)))
//        
//        if(randomIndex>0)
//        {
//            randomIndex -= 1
//        }
//      
        
        //get sentence from server
        var questionSentence: Dictionary<String, String>? = callToScript("https://arcane-depths-56902.herokuapp.com/gameStatus.php?q=getQuestion")
        
        randomQuestionSentence = questionSentence!["randomQuestionSentence"]!
        
        
//        randomQuestionSentence = createRandomSentence()
        questionString.text = randomQuestionSentence
        
        //send question sentence to all players
//        callToScript("https://arcane-depths-56902.herokuapp.com/gameStatus.php?q=update")
//        let messageDict = ["randomQuestionSentence":randomQuestionSentence]
//        
//        do{
//            let messageData = try? NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted)
//            
//            try? appDelegate.mpcHandler.session.sendData(messageData!, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
//            
//        }catch let error as NSError {
//            print("An error occurred: \(error)")
//        }
    }
    
    
    
    
    //function to handle sentence receipt
//    func handleReceivedDataWithNotification(notification:NSNotification){
//        
//        //extract message from notification
//        let userInfo = notification.userInfo! as Dictionary
//        let receivedData:NSData = userInfo["data"] as! NSData
//        
//        let message = try? NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
//        
////        let senderPeerId:MCPeerID = userInfo["peerID"] as! MCPeerID
////        let senderDisplayName = senderPeerId.displayName
//        
//        
//        //set received sentence
//        randomQuestionSentence = message!.objectForKey("randomQuestionSentence")! as! String
//        questionString.text = randomQuestionSentence
//
//    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject!) -> Bool {
        if identifier == "inputToScore" {
            
            if (userInput.text!.isEmpty) {
                
                //Newer way to use an alert
                let alert = UIAlertController(title: "Oops", message: "You must type something", preferredStyle: UIAlertControllerStyle.Alert)
                
                self.presentViewController(alert, animated: true, completion: nil)

                alert.addAction(
                    UIAlertAction(title: "Start Typing!", style: UIAlertActionStyle.Default) { (action) -> Void in
                        print("")})
                
//                Deprecated way
//                let alert = UIAlertView()
//                alert.title = "Oops"
//                alert.message = "I think you forgot to type"
//                alert.addButtonWithTitle("Start typing!")
//                alert.show()
                
                return false
            }
            else {
                return true
            }
        }
        
        // by default, transition
        return true
    }
    
    
//    func callToScript(url: String){
//        var data = NSData(contentsOfURL: NSURL(string: url)!)
////        print("data: \(data)")
//    }
    
    func callToScript(url: String) -> Dictionary<String,String>? {
        
        let data = NSData(contentsOfURL: NSURL(string: url)!)
        do {
            
            var jsonArray = try? NSJSONSerialization.JSONObjectWithData(data!, options: [NSJSONReadingOptions.MutableContainers, NSJSONReadingOptions.AllowFragments]) as? Dictionary<String, String>
            
            //            print("json se count := \(jsonArray!!["count"])")
            if jsonArray == nil{
                jsonArray = ["":""]
            }
            return jsonArray!;
            
        }catch let error as NSError {
            print(error.localizedDescription)
            return nil;
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
            if segue.identifier == "inputToScore"{
                
                timer.invalidate()
                let svc = segue.destinationViewController as! ScoreViewController
                svc.answer = userInput.text
                svc.question = questionString.text
//                svc.totalTime = countingLabel.text
                svc.appDelegate = self.appDelegate
//                callToScript("http://jaikhanna.byethost7.com/Jai_Khanna_Profile/Projects/FasType/gameStatus.php?q=update")
                let callResult = callToScript("https://arcane-depths-56902.herokuapp.com/gameStatus.php?q=update")
            }
    }
    
    func updateCounter(){
        countingLabel.text = String(counter++)
    }
}

