//
//  ViewController.swift
//  FasType
//
//  Created by Jai Khanna on 11/14/15.
//  Copyright © 2015 Jai Khanna. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var sentences = ["hello world", "kya haal hai?"]
       
    @IBOutlet weak var userInput: UITextField!
    
    
    
    @IBAction func submitResponse(sender: UIButton) {
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
        let label = UILabel(frame: CGRectMake(0, 0, 100, 21))
        label.center = CGPointMake(160, 284)
        label.textAlignment = NSTextAlignment.Center
        label.text = sentences[0]
        self.view.addSubview(label)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

