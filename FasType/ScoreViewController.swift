//
//  ScoreViewController.swift
//  FasType
//
//  Created by Jai Khanna on 11/14/15.
//  Copyright © 2015 Jai Khanna. All rights reserved.
//

import Foundation
import UIKit

class ScoreViewController: UIViewController {
    
   
    @IBOutlet weak var userScore: UILabel!
    @IBOutlet weak var misMatch: UILabel!
    @IBOutlet weak var timeTaken: UILabel!
    
    var answer: String!
    var question: String!
    var levScore: Double!
    var finalScore: Double!
    var questionLen: Double!
    var totalTime: String!
    
    
    
    
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
        
        var dist = Array2D(cols: a.count + 1, rows: b.count + 1)
        
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
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        if answer == ""{
            
        }else{
            questionLen = Double(question.characters.count)
            levScore = Double(levenshtein(answer,bStr: question))
            
            finalScore = round(((questionLen - levScore)/questionLen) * 100)
            userScore.text = "Your score is: \(Int(finalScore)) %"
            misMatch.text = "Mismatch character(s): \(Int(levScore))"
            timeTaken.text = "You took \(totalTime) seconds"
            
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if segue.identifier == "resetGame"{
            let qvc = segue.destinationViewController as! QuestionViewController
        }
    }
    
}
