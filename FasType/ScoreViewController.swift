//
//  ScoreViewController.swift
//  FasType
//
//  Created by Jai Khanna on 11/14/15.
//  Copyright © 2015 Jai Khanna. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity

class ScoreViewController: UIViewController {
    
    @IBOutlet weak var userScore: UILabel!
    @IBOutlet weak var misMatch: UILabel!
    @IBOutlet weak var timeTaken: UILabel!
    
    var appDelegate: AppDelegate!
    var answer: String!
    var question: String!
    var levScore: Double!
    var finalScore: Double!
    var questionLen: Double!
    var totalTime: String!
    var playerScores = [MCPeerID: Int]()
    var data: NSArray = []
    var changeCode: Int = 0
    var numberOfPlayersDone: Int = 0
    
    func min(numbers: Int...) -> Int {
        return numbers.reduce(numbers[0], combine: {$0 < $1 ? $0 : $1})
    }
    
    class Array2D {
        var cols:Int, rows:Int
        var matrix: [Int]
        
        
        init(cols:Int, rows:Int) {
            self.cols = cols
            self.rows = rows
            matrix = Array(count:cols*rows, repeatedValue:0)
        }
        
        subscript(col:Int, row:Int) -> Int {
            get {
                return matrix[cols * row + col]
            }
            set {
                matrix[cols*row+col] = newValue
            }
        }
        
        func colCount() -> Int {
            return self.cols
        }
        
        func rowCount() -> Int {
            return self.rows
        }
    }
    
    func levenshtein(aStr: String, bStr: String) -> Int {
        let a = Array(aStr.utf16)
        let b = Array(bStr.utf16)
        
        let dist = Array2D(cols: a.count + 1, rows: b.count + 1)
        
        for i in 1...a.count {
            dist[i, 0] = i
        }
        
        for j in 1...b.count {
            dist[0, j] = j
        }
        
        for i in 1...a.count {
            for j in 1...b.count {
                if a[i-1] == b[j-1] {
                    dist[i, j] = dist[i-1, j-1]  // noop
                } else {
                    dist[i, j] = min(
                        dist[i-1, j] + 1,  // deletion
                        dist[i, j-1] + 1,  // insertion
                        dist[i-1, j-1] + 1  // substitution
                    )
                }
            }
        }
        
        return dist[a.count, b.count]
    }
    
    override func viewDidLoad() {
        
        //add notification observer
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleReceivedDataWithNotification:", name: "MPC_DidReceiveDataNotification", object: nil)
        
        if answer == ""{
            
        }else{
            
            //calculate the score
            questionLen = Double(question.characters.count)
            levScore = Double(levenshtein(answer,bStr: question))
            
            self.finalScore = round(((questionLen - levScore)/questionLen) * 100)
            
            //PJ algo variables - our 80/20 algo
            let typingAvg = 150 //=> 150 chars/minute
            let typingAvgPerSec = 0.4 //=> 0.4 seconds/char
            let typingAvgCurrentQuestion = questionLen*0.4
            
            var accuracy80 = (finalScore*80)/100
            var time20 = (200 - ((Double(totalTime)! * 100)/typingAvgCurrentQuestion))/5
            
            finalScore = accuracy80 + time20
            
            if finalScore<0{
                finalScore = 0
            }
            
            //update Score Card UI
            misMatch.text = "Mismatch character(s): \(Int(levScore))"
            timeTaken.text = "You took \(totalTime) seconds"
            userScore.text = "Your score is: \(Int(finalScore)) %"
            
            //update self score to playerScores
            playerScores[appDelegate.mpcHandler.session.myPeerID] = Int(self.finalScore)
            
            //check if all players are on the same page
            var checkPlayerDoneCount: Dictionary<String, String>? = callToScript("https://arcane-depths-56902.herokuapp.com/gameStatus.php?q=retrieve")
            
            var count = Int(checkPlayerDoneCount!["count"]!)
            
            while(count < appDelegate.mpcHandler.session.connectedPeers.count+1){
                print("checking status")
                sleep(1)
                checkPlayerDoneCount = callToScript("https://arcane-depths-56902.herokuapp.com/gameStatus.php?q=retrieve")
                count = Int(checkPlayerDoneCount!["count"]!)
                continue
            }
            
            //comes here only when all players are on the same page - aka ready-to-receive-data state
            
            //send self score to every other player
            let messageDict = ["score":Int(self.finalScore)]
            
            do{
                let messageData = try? NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted)
                
                try? appDelegate.mpcHandler.session.sendData(messageData!, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
                
            }catch let error as NSError {
                print("An error occurred: \(error)")
            }
        }
    }
    
    //function to handle data receipt
    func handleReceivedDataWithNotification(notification:NSNotification){
        
        //extract message from notification
        let userInfo = notification.userInfo! as Dictionary
        let receivedData:NSData = userInfo["data"] as! NSData
        
        let message = try? NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
        
        let senderPeerId:MCPeerID = userInfo["peerID"] as! MCPeerID
        let senderDisplayName = senderPeerId.displayName
    
        //request for new game
        if message!.objectForKey("status")?.isEqualToString("New Game") == true{
            
            changeCode = message!.objectForKey("changeCode")!.integerValue
            
            let alert1 = UIAlertController(title: "FasType", message: "\(senderDisplayName) has started a new game", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert1.addAction(
                UIAlertAction(title: "Challenge Accepted!", style: UIAlertActionStyle.Default) { (action) -> Void in

                    //take each player back to the questions page
                    self.performSegueWithIdentifier("resetGame", sender: self)
                    
                })
            
            self.presentViewController(alert1, animated: true, completion: nil)
            
        }
            
        //score receipt
        else{
            
            var score:Int = message!.objectForKey("score")!.integerValue
            
            print("score received from \(senderDisplayName)")
            
            //add sender player and its score to the dictionary
            playerScores[senderPeerId] = score
            
            checkResults()
        }
    }

    func checkResults(){

        var winner: String = ""
 
        if(playerScores.count == appDelegate.mpcHandler.session.connectedPeers.count+1)
        {
            print("inside checkResults ka IF")
            
            var maxScore: Int = -999999
            
            var checkTie: Int = 0
            var tieScore: Int = 0
            var i: Int = 0
            var flag = 0
            
            //check for a tie
            for (playerId, score) in playerScores {
                
                if(i == 0){
                    tieScore = score
                    i++
                }
                else{
                    if(score == tieScore){
                        checkTie++
                    }
                    else{
                        break
                    }
                }
            }

            //find winner
            for (playerId, score) in playerScores {
                print("\(score): \(playerId)")
                
                if(score>maxScore){
                    maxScore = score
                    winner = playerId.displayName
                }
            }
            
            print("flag: \(flag)")
            
            if(checkTie == appDelegate.mpcHandler.session.connectedPeers.count){
                
                let alert = UIAlertController(title: "Results", message: "Its a tie guys!", preferredStyle: UIAlertControllerStyle.Alert)
                
                alert.addAction(
                    UIAlertAction(title: "Huh!", style: UIAlertActionStyle.Default) { (action) -> Void in
                        print("")
                    })
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
            //if not a tie
            else{
                
                //declare winner
                let alert = UIAlertController(title: "Results", message: "The winner is \(winner)", preferredStyle: UIAlertControllerStyle.Alert)
                
                alert.addAction(
                    UIAlertAction(title: "Ok!", style: UIAlertActionStyle.Default) { (action) -> Void in
                        print("")
                        print(self.playerScores)
                        
                        //alert all results - aka resultsView
                        
                        var resultsMessage: String = ""
                        
                        for (playerId1, score1) in self.playerScores {
                            
                            resultsMessage += "\(playerId1.displayName) scored \(score1)% \r\n"
                        }
                        
                        print("resultsMessage: \(resultsMessage)")
                        
                        let alert = UIAlertController(title: "Results", message: resultsMessage, preferredStyle: UIAlertControllerStyle.Alert)
                        
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) { (action) -> Void in })
                        
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                        let clearAll: Dictionary<String, String>? = self.callToScript("https://arcane-depths-56902.herokuapp.com/gameStatus.php?q=clearAll")
                    })
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
        }else{
            //TODO (maybe): alert saying 'waiting for other players to complete"
        }
    }
    
    func newGame(){
        
        self.playerScores.removeAll()
        let messageDict = ["status":"New Game", "changeCode": "1"]
        
        let messageData = try? NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted)
        
        do {
            try? appDelegate.mpcHandler.session.sendData(messageData!, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
        } catch let error1 as NSError {
            print(error1)
        }
        
        if changeCode == 0 {
            let clearAll: Dictionary<String, String>? = self.callToScript("https://arcane-depths-56902.herokuapp.com/gameStatus.php?q=clearAll")
        }
    }
    
    func callToScript(url: String) -> Dictionary<String,String>? {
        
        let data = NSData(contentsOfURL: NSURL(string: url)!)
        do {
            var jsonArray = try? NSJSONSerialization.JSONObjectWithData(data!, options: [NSJSONReadingOptions.MutableContainers, NSJSONReadingOptions.AllowFragments]) as? Dictionary<String, String>
            
            if jsonArray == nil{
                jsonArray = ["":""]
            }
            return jsonArray!;
            
        }catch let error as NSError {
            print(error.localizedDescription)
            return nil;
        }
    }
    
    //button to view the results
    @IBAction func viewResults(sender: AnyObject) {
        
        //create message string with the results
        var resultsMessage: String = ""
        
        for (playerId, score) in playerScores {
            resultsMessage += "\(playerId.displayName) scored \(score)% \r\n"
        }
        
        print("resultsMessage: \(resultsMessage)")
        
        let alert = UIAlertController(title: "Results", message: resultsMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) { (action) -> Void in })
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func leaveSession(sender: AnyObject) {
        appDelegate.mpcHandler.session.disconnect()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        
        if segue.identifier == "resetGame"{
            self.newGame()
            let qvc = segue.destinationViewController as! QuestionViewController
            qvc.appDelegate = appDelegate
        }
    }
}