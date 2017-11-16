//
//  ViewController.swift
//  CocoaHealth-Starter
//
//  Created by Steven Shang on 11/15/17.
//  Copyright © 2017 cocoanuts. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var bodyMassIndexLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var averageStepsLabel: UILabel!
    @IBOutlet weak var averageDistanceLabel: UILabel!
    @IBOutlet weak var averageFlightsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func weightTextFieldEditingEnded(_ sender: Any) {
    }
    
    @IBAction func heightTextfieldEditingEnded(_ sender: Any) {
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
    }
    
}

