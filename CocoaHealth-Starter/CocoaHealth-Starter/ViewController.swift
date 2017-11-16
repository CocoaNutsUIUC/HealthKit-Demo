//
//  ViewController.swift
//  CocoaHealth-Starter
//
//  Created by Steven Shang on 11/15/17.
//  Copyright © 2017 cocoanuts. All rights reserved.
//

import UIKit
import HealthKit

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
        askForHealthKitAccess()
        weightTextField.delegate = self
        heightTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func weightTextFieldEditingEnded(_ sender: Any) {
        guard let newText = weightTextField.text, let newWeight = Double(newText) else {
            return
        }
        weight = newWeight
    }
    
    @IBAction func heightTextfieldEditingEnded(_ sender: Any) {
        guard let newText = heightTextField.text, let newHeight = Double(newText) else {
            return
        }
        height = newHeight
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        saveUserData()
    }
    
    private func askForHealthKitAccess() {
        
        HealthKitController.sharedInstance.authorizeHealthKit { (sucess, error) in
            if !sucess, let error = error {
                self.showAlert(title: "HealthKit Authentication Failed", message: error.localizedDescription)
            } else {
                self.readWeightAndHeight()
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private var weight: Double? = nil {
        didSet {
            CalculateBMI()
        }
    }
    
    private var height: Double? = nil {
        didSet {
            CalculateBMI()
        }
    }
    
    private var bodyMassIndex: Double? = nil {
        didSet {
            updateUI()
        }
    }
    
    private func readWeightAndHeight() {
        
        guard let heightType = HKSampleType.quantityType(forIdentifier: .height),
            let weightType = HKSampleType.quantityType(forIdentifier: .bodyMass) else {
                print("Something horrible has happened.")
                return
        }
        HealthKitController.sharedInstance.readMostRecentSample(for: heightType) { (sample, error) in
            if let sample = sample {
                self.height = sample.quantity.doubleValue(for: HKUnit.foot())
            }
        }
        HealthKitController.sharedInstance.readMostRecentSample(for: weightType) { (sample, error) in
            if let sample = sample {
                self.weight = sample.quantity.doubleValue(for: HKUnit.pound())
            }
        }
        updateUI()
    }
    
    private func saveUserData() {
        
        // Prepare Data
        guard let weight = weight,
            let height = height,
            let bodyMassIndex = bodyMassIndex else {
                return
        }
        guard let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass),
            let heightType = HKQuantityType.quantityType(forIdentifier: .height),
            let bodyMassIndexType = HKQuantityType.quantityType(forIdentifier: .bodyMassIndex) else {
                print("Something terrible has happened.")
                return
        }
        
        let weightQuantity = HKQuantity(unit: HKUnit.pound(), doubleValue: weight)
        let heightQuantity = HKQuantity(unit: HKUnit.foot(), doubleValue: height)
        let bodyMassIndexQuantity = HKQuantity(unit: HKUnit.count(), doubleValue: bodyMassIndex)
        
        // Save Data
        var errorOccured = false
        HealthKitController.sharedInstance.writeSample(for: weightType, sampleQuantity: weightQuantity) { (sucess, error) in
            if !sucess, let error = error {
                errorOccured = true
                print(error.localizedDescription)
            }
        }
        HealthKitController.sharedInstance.writeSample(for: heightType, sampleQuantity: heightQuantity) { (sucess, error) in
            if !sucess, let error = error {
                errorOccured = true
                print(error.localizedDescription)
            }
        }
        HealthKitController.sharedInstance.writeSample(for: bodyMassIndexType, sampleQuantity: bodyMassIndexQuantity) { (sucess, error) in
            if !sucess, let error = error {
                errorOccured = true
                print(error.localizedDescription)
            }
        }
        
        // Error Handling
        if errorOccured {
            showAlert(title: "Failed to Save Data", message: "Some error occured while writing to HealthKit.")
        } else {
            showAlert(title: "Success!", message: "Successfully saved your data to HealthKit.")
        }
    }
    
    private func updateUI() {
        
        DispatchQueue.main.async {
            if let weight = self.weight {
                self.weightTextField.text = String(weight)
            }
            if let height = self.height {
                self.heightTextField.text = String(height)
            }
            if let bodyMassIndex = self.bodyMassIndex {
                self.bodyMassIndexLabel.text = String(bodyMassIndex)
            } else {
                self.bodyMassIndexLabel.text = "Unknown"
            }
        }
    }
    
    private func CalculateBMI() {
        // BMI = weight / height^2
        
        guard let weight = weight, let height = height, height > 0 else {
            return
        }
        let weightInKiloG = Measurement(value: weight, unit: UnitMass.pounds).converted(to: UnitMass.kilograms).value
        let heightInMeter = Measurement(value: height, unit: UnitLength.feet).converted(to: UnitLength.meters).value
        bodyMassIndex = weightInKiloG/(heightInMeter * heightInMeter)
    }
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
