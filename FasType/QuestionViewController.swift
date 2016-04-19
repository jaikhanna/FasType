//
//  QuestionViewController.swift
//  FasType
//
//  Created by Jai Khanna on 11/14/15.
//  Copyright © 2015 Jai Khanna. All rights reserved.
//
import UIKit
import MultipeerConnectivity

class QuestionViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var questionString: UILabel!
    @IBOutlet weak var userInput: UITextField!
    @IBOutlet weak var countingLabel: UILabel!
    
    var timer = NSTimer()
    var counter = 0
    var appDelegate:AppDelegate!
    var randomQuestionSentence: String = ""
    
    @IBAction func submitResponse(sender: UIButton) {
    }
    
    func textFieldShouldReturn(userText: UITextField!) -> Bool {
        userText.resignFirstResponder()
        return true;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        [userInput .becomeFirstResponder()]
        self.userInput.delegate = self
        
        //Timer UI
        countingLabel.layer.borderWidth = 5.0
        countingLabel.layer.borderColor = UIColor.magentaColor().CGColor
        countingLabel.layer.cornerRadius = 50
        
        //questionString UI
        questionString.layer.borderWidth = 2.0
        questionString.layer.borderColor = UIColor.magentaColor().CGColor
        questionString.layer.cornerRadius = 8
        questionString.layer.masksToBounds = true
        
        //set keyboard as 'done' type
        userInput.returnKeyType = UIReturnKeyType.Done
        
        //set the timer
        countingLabel.text = String(counter)
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateCounter"), userInfo: nil, repeats: true)
    
        //get sentence from server
        var questionSentence: Dictionary<String, String>? = callToScript("https://arcane-depths-56902.herokuapp.com/gameStatus.php?q=getQuestion")
        
        randomQuestionSentence = questionSentence!["randomQuestionSentence"]!
        
        questionString.text = randomQuestionSentence
    }
    
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
                
                return false
            }
            else {
                return true
            }
        }
        
        // by default, transition
        return true
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
            if segue.identifier == "inputToScore"{
                
                timer.invalidate()
                let svc = segue.destinationViewController as! ScoreViewController
                svc.answer = userInput.text
                svc.question = questionString.text
                svc.totalTime = countingLabel.text
                svc.appDelegate = self.appDelegate
                let callResult = callToScript("https://arcane-depths-56902.herokuapp.com/gameStatus.php?q=update")
            }
    }
    
    func updateCounter(){
        countingLabel.text = String(counter++)
    }
}