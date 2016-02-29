//
//  QuestionViewController.swift
//  FasType
//
//  Created by Jai Khanna on 11/14/15.
//  Copyright © 2015 Jai Khanna. All rights reserved.
//

import UIKit

class QuestionViewController: UIViewController {
    
    var sentences = ["hello world", "HackSC", "Two Sigma","bonjour", "Apple", "Microsoft", "jaikhanna","pranshu"]
       
    @IBOutlet weak var questionString: UILabel!
    @IBOutlet weak var userInput: UITextField!
    
    @IBOutlet var countingLabel: UILabel!
    var timer = NSTimer()
    var counter = 0
    
    
    
    @IBAction func submitResponse(sender: UIButton) {
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        [userInput .becomeFirstResponder()]
        
        countingLabel.text = String(counter)
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateCounter"), userInfo: nil, repeats: true)
        
        self.navigationItem.setHidesBackButton(true, animated:true);
        var randomIndex = Int(arc4random_uniform(UInt32(sentences.count)))
        
        if(randomIndex>0)
        {
            randomIndex -= 1
        }
        questionString.text = sentences[randomIndex]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject!) -> Bool {
        if identifier == "inputToScore" {
            
            if (userInput.text!.isEmpty) {
                
                let alert = UIAlertView()
                alert.title = "Oops"
                alert.message = "I think you forgot to type"
                alert.addButtonWithTitle("Start typing!")
                alert.show()
                
                return false
            }
                
            else {
                return true
            }
        }
        
        // by default, transition
        return true
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
            if segue.identifier == "inputToScore"{
                
                timer.invalidate()
                let svc = segue.destinationViewController as! ScoreViewController
                svc.answer = userInput.text
                svc.question = questionString.text
                svc.totalTime = countingLabel.text
            }
    }
    
    func updateCounter(){
        countingLabel.text = String(counter++)
    }

}

