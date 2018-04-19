//
//  PopupViewController.swift
//  KANA
//
//  Created by Hoijan Lai on 31/01/2018.
//  Copyright © 2018 Hoijan Lai. All rights reserved.
//

import UIKit

class PopupViewController: UIViewController {

    
    @IBOutlet weak var correctLabel: UILabel!
    @IBOutlet weak var checkLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    var targetLabel: String = ""
    var userWritting: String = ""
    var testBool: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        userLabel!.text = userWritting
        correctLabel!.text = targetLabel
        checkLabel!.text = (targetLabel == userWritting) ? "Correct" : "Sorry, It should be.."
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func Next_TUI(_ sender: Any) {
        dismiss(animated: true)
    }
    
}
