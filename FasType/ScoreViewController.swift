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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleReceivedDataWithNotification:", name: "MPC_DidReceiveDataNotification", object: nil)
        
        
        if answer == ""{
            
        }else{
            questionLen = Double(question.characters.count)
            levScore = Double(levenshtein(answer,bStr: question))
            
            finalScore = round(((questionLen - levScore)/questionLen) * 100)
            userScore.text = "Your score is: \(Int(finalScore)) %"
            misMatch.text = "Mismatch character(s): \(Int(levScore))"
            timeTaken.text = "You took \(totalTime) seconds"
            
            //update self score to playerScores
            playerScores[Int(finalScore)] = appDelegate.mpcHandler.session.myPeerID
            
            //send score to all connected players/peers
            let messageDict = ["score":Int(finalScore)]
            
            do{
                let messageData = try? NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted)
                
                try appDelegate.mpcHandler.session.sendData(messageData!, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
                
            }catch let error as NSError {
                print("An error occurred: \(error)")
            }
            
            checkResults()
        }
        
    }
    
    func handleReceivedDataWithNotification(notification:NSNotification){
       
        print("This confirms data receipt in ScoreView")
        
        //extract message
        let userInfo = notification.userInfo! as Dictionary
        let receivedData:NSData = userInfo["data"] as! NSData
        
        do {
            let message = try? NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
            
            let senderPeerId:MCPeerID = userInfo["peerID"] as! MCPeerID
            let senderDisplayName = senderPeerId.displayName
            
            if message!.objectForKey("status")?.isEqualToString("New Game") == true{
                let alert1 = UIAlertController(title: "FasType", message: "\(senderDisplayName) has started a new game", preferredStyle: UIAlertControllerStyle.Alert)
                
                alert1.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                
                self.presentViewController(alert1, animated: true, completion: nil)
                
                resetGame()
            }
            else if message!.objectForKey("winnerChosen")?.isEqualToString("true") == true{

                var winner:String = message!.objectForKey("winner") as! String
                
                let alert = UIAlertController(title: "Results", message: "The winner is \(winner)", preferredStyle: UIAlertControllerStyle.Alert)
                
                alert.addAction(
                    UIAlertAction(title: "Ok! Start Again!", style: UIAlertActionStyle.Default) { (action) -> Void in
                        print("")
                        self.newGame()
                        print(self.numberOfPlayersDone)
                        print(self.playerScores)
                    })
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
            else{
                //var playerId:String? = message!.objectForKey("playerId") as? String
                var score:Int = message!.objectForKey("score")!.integerValue
                
                //increment player done count
                numberOfPlayersDone++
                
                print(senderDisplayName)
                
                //add player and its score to the dictionary
                playerScores[score] = senderPeerId
                
                checkResults()
            }
        }catch let error as NSError {
             print("An error occurred: \(error)")
         }
            
        
        
    }
    
    
    func checkResults(){
        print("inside checkResults")
        
        var winner: String = ""
        var maxScore: Int = -999999
        
        for (score, playerId) in playerScores {
            print("\(score): \(playerId)")
            
            if(score>maxScore){
                maxScore = score
                winner = playerId.displayName
            }
        }
        
        if winner != ""{
            
            let messageDict = ["winnerChosen":"true", "winner": winner]
            
            let messageData = try? NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted)
            
            do {
                try appDelegate.mpcHandler.session.sendData(messageData!, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            } catch let error1 as NSError {
                print(error1)
            }
        }
        
        
        
        
        
        
//        //testing if alert goes to all
//        if winner != ""{
//            let messageDict = ["winnerChosen":"true", "winner": "jai"]
//            
//            let messageData = try? NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted)
//            
//            do {
//                try appDelegate.mpcHandler.session.sendData(messageData!, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
//            } catch let error1 as NSError {
//                print(error1)
//            }
//        }
//
//        if(playerScores.count == appDelegate.mpcHandler.session.connectedPeers.count+1)
//        {
//            var maxScore: Int = -999999
//            var checkTie: Int = 0
//            
//            
//            
//            for (score, playerId) in playerScores {
//                print("\(score): \(playerId)")
//                
//                if(score>maxScore){
//                    maxScore = score
//                    winner = playerId.displayName
//                }
//                else if(score == maxScore){
//                    checkTie++
//                }
//            }
//            
//            if(checkTie == appDelegate.mpcHandler.session.connectedPeers.count){
//                let alert = UIAlertController(title: "Results", message: "Its a tie guys!", preferredStyle: UIAlertControllerStyle.Alert)
//                
//                alert.addAction(
//                    UIAlertAction(title: "Huh!", style: UIAlertActionStyle.Default) { (action) -> Void in
//                        print("")
//                        self.newGame()
//                    })
//                
//                self.presentViewController(alert, animated: true, completion: nil)
//            }
//            else{
//                //testing if alert goes to all
////                let messageDict = ["winnerChosen":"true", "winner": winner]
////                
////                let messageData = try? NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted)
////                
////                do {
////                    try appDelegate.mpcHandler.session.sendData(messageData!, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
////                } catch let error1 as NSError {
////                    print(error1)
////                }
//                
////                let alert = UIAlertController(title: "Results", message: "The winner is \(winner)", preferredStyle: UIAlertControllerStyle.Alert)
////                
////                alert.addAction(
////                    UIAlertAction(title: "Ok! Start Again!", style: UIAlertActionStyle.Default) { (action) -> Void in
////                        print("")
////                        self.newGame()
////                        print(self.numberOfPlayersDone)
////                        print(self.playerScores)
////                    })
////                
////                self.presentViewController(alert, animated: true, completion: nil)
//                
//            }
//
//            
//        }else{
//            //TODO (maybe): alert saying 'waiting for other players to complete"
//        }
    }
    
    func resetGame(){
        self.playerScores.removeAll()
        self.numberOfPlayersDone = 0
    }
    
    func newGame(){
        resetGame()
        
        let messageDict = ["status":"New Game"]
        
        let messageData = try? NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted)
        
        do {
            try appDelegate.mpcHandler.session.sendData(messageData!, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
        } catch let error1 as NSError {
            print(error1)
        }
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if segue.identifier == "resetGame"{
            let qvc = segue.destinationViewController as! QuestionViewController
            qvc.appDelegate = appDelegate
        }
    }
    
}
