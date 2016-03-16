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
    var playerScores = [Int: MCPeerID]()
//    var winner: String = ""
    var x: Dictionary<String,String>?
    var data: NSArray = []
    
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
            userScore.text = "Your score is: \(Int(finalScore)) %"
            misMatch.text = "Mismatch character(s): \(Int(levScore))"
            timeTaken.text = "You took \(totalTime) seconds"
            
            
            //update self score to playerScores
            playerScores[Int(self.finalScore)] = appDelegate.mpcHandler.session.myPeerID
            
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
            
            //comes here only when all players are on the same page
            //now, send every player's score to every other player
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
       
        print("This confirms data receipt in ScoreView")
        
        //extract message from notification
        let userInfo = notification.userInfo! as Dictionary
        let receivedData:NSData = userInfo["data"] as! NSData
        
//        do {
            let message = try? NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
            
            let senderPeerId:MCPeerID = userInfo["peerID"] as! MCPeerID
            let senderDisplayName = senderPeerId.displayName
            
            
            //request for new game
            if message!.objectForKey("status")?.isEqualToString("New Game") == true{
                let alert1 = UIAlertController(title: "FasType", message: "\(senderDisplayName) has started a new game", preferredStyle: UIAlertControllerStyle.Alert)
                
                alert1.addAction(
                    UIAlertAction(title: "Challenge Accepted!", style: UIAlertActionStyle.Default) { (action) -> Void in
                        let clearAll: Dictionary<String, String>? = self.callToScript("https://arcane-depths-56902.herokuapp.com/gameStatus.php?q=clearAll")
                        
                        
                        self.newGame()
                        
                        //TODO: take each player back to the questions page
                        self.performSegueWithIdentifier("resetGame", sender: self)
                        
                    })
                
                self.presentViewController(alert1, animated: true, completion: nil)
                
            }
                
                
            //winner chosen
//            else if message!.objectForKey("winnerChosen")?.isEqualToString("true") == true{
//
//                var winner:String = message!.objectForKey("winner") as! String
//                
//                let alert = UIAlertController(title: "Results", message: "The winner is \(winner)", preferredStyle: UIAlertControllerStyle.Alert)
//                
//                alert.addAction(
//                    UIAlertAction(title: "Ok!", style: UIAlertActionStyle.Default) { (action) -> Void in
//                        print("")
//                        print(self.numberOfPlayersDone)
//                        print(self.playerScores)
//                        let clearAll: Dictionary<String, String>? = self.dataOfJson("https://arcane-depths-56902.herokuapp.com/gameStatus.php?q=clearAll")
//                    })
//                
//                self.presentViewController(alert, animated: true, completion: nil)
//            }
                
                
            //score receipt
            else{
                //var playerId:String? = message!.objectForKey("playerId") as? String
                
                //extract score
                var score:Int = message!.objectForKey("score")!.integerValue
                
                //increment player done count
//                numberOfPlayersDone++
                
                print("score received from \(senderDisplayName)")
                
                //add player and its score to the dictionary
                playerScores[score] = senderPeerId
                
                checkResults()
            }
//        }catch let error as NSError {
//             print("An error occurred: \(error)")
//         }
        
        
        
    }
    
    
    func checkResults(){
        
        print("inside checkResults")

        var winner: String = ""
 
        if(playerScores.count == appDelegate.mpcHandler.session.connectedPeers.count+1)
        {
            var maxScore: Int = -999999
            var checkTie: Int = 0
            var tieScore: Int = 0
            var i: Int = 0
            
            
            //check for a tie
            
            for (score, playerId) in playerScores {
                
                if(i == 0){
                    tieScore = score
                    i++
                }
                    
                if(score == tieScore){
                    checkTie++
                }
            }

            
            
            //find winner
            for (score, playerId) in playerScores {
                print("\(score): \(playerId)")
                
                if(score>maxScore){
                    maxScore = score
                    winner = playerId.displayName
                }
            }
            
            if(checkTie == appDelegate.mpcHandler.session.connectedPeers.count+1){
                let alert = UIAlertController(title: "Results", message: "Its a tie guys!", preferredStyle: UIAlertControllerStyle.Alert)
                
                alert.addAction(
                    UIAlertAction(title: "Huh!", style: UIAlertActionStyle.Default) { (action) -> Void in
                        print("")
                        var clearAll: Dictionary<String, String>? = self.callToScript("https://arcane-depths-56902.herokuapp.com/gameStatus.php?q=clearAll")
                        self.newGame()
                    })
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else{
                
                //self alert now
                let alert = UIAlertController(title: "Results", message: "The winner is \(winner)", preferredStyle: UIAlertControllerStyle.Alert)
                
                alert.addAction(
                    UIAlertAction(title: "Ok!", style: UIAlertActionStyle.Default) { (action) -> Void in
                        print("")
                        print(self.playerScores)
                        
                        //testing resultsView
                        
                        var resultsMessage: String = ""
                        
                        for (score1, playerId1) in self.playerScores {
                            
                            resultsMessage += "\(playerId1.displayName) scored \(score1)% \r\n"
                        }
                        
                        print("resultsMessage: \(resultsMessage)")
                        
                        let alert = UIAlertController(title: "Results", message: resultsMessage, preferredStyle: UIAlertControllerStyle.Alert)
                        
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) { (action) -> Void in })
                        
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                        
                        //testing ends here
                        
                        
                        
                        
                        
                        
                        let clearAll: Dictionary<String, String>? = self.callToScript("https://arcane-depths-56902.herokuapp.com/gameStatus.php?q=clearAll")
                    })
                
                self.presentViewController(alert, animated: true, completion: nil)
                
                //self alert end
                
//                let messageDict = ["winnerChosen":"true", "winner": winner]
//                
//                let messageData = try? NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted)
//                
//                do {
//                    try? appDelegate.mpcHandler.session.sendData(messageData!, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
//                } catch let error1 as NSError {
//                    print(error1)
//                }
                
//                let alert = UIAlertController(title: "Results", message: "The winner is \(winner)", preferredStyle: UIAlertControllerStyle.Alert)
//                
//                alert.addAction(
//                    UIAlertAction(title: "Ok! Start Again!", style: UIAlertActionStyle.Default) { (action) -> Void in
//                        print("")
//                        self.newGame()
//                        print(self.numberOfPlayersDone)
//                        print(self.playerScores)
//                    })
//                
//                self.presentViewController(alert, animated: true, completion: nil)
                
            }

            
        }else{
            //TODO (maybe): alert saying 'waiting for other players to complete"
        }
    }
    
    func newGame(){
        
        self.playerScores.removeAll()
        let messageDict = ["status":"New Game"]
        
        let messageData = try? NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted)
        
        do {
            try? appDelegate.mpcHandler.session.sendData(messageData!, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
        } catch let error1 as NSError {
            print(error1)
        }
    }
    
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
    
    //button to view the results
    @IBAction func viewResults(sender: AnyObject) {
        //create message string with the results
        var resultsMessage: String = ""
        
        for (score, playerId) in playerScores {
            //            print("\(score): \(playerId)")
            resultsMessage += "\(playerId.displayName) scored \(score)% \r\n"
        }
        
        print("resultsMessage: \(resultsMessage)")
        
        let alert = UIAlertController(title: "Results", message: resultsMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) { (action) -> Void in })
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        
        if segue.identifier == "resetGame"{
            self.newGame()
            let qvc = segue.destinationViewController as! QuestionViewController
            qvc.appDelegate = appDelegate
        }
    }
    
}