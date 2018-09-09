//
//  ActivityViewController.swift
//  CocoaHealth-Starter
//
//  Created by Steven Shang on 9/8/18.
//  Copyright © 2018 cocoanuts. All rights reserved.
//

import UIKit
import HealthKit

class ActivityViewController: UIViewController {

    @IBOutlet weak var averageStepsLabel: UILabel!
    @IBOutlet weak var averageDistanceLabel: UILabel!
    @IBOutlet weak var averageFlightsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        readActivitiesData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func updateUI() {

        DispatchQueue.main.async {
            if let averageSteps = self.averageSteps {
                self.averageStepsLabel.text = String(averageSteps)
            } else {
                self.averageStepsLabel.text = "Unknown"
            }
            if let averageDistance = self.averageDistance {
                self.averageDistanceLabel.text = String(averageDistance)
            } else {
                self.averageDistanceLabel.text = "Unknown"
            }
            if let averageFlights = self.averageFlights {
                self.averageFlightsLabel.text = String(averageFlights)
            } else {
                self.averageFlightsLabel.text = "Unknwon"
            }
        }
    }

    private var averageSteps: Int? {
        didSet {
            updateUI()
        }
    }
    
    private var averageDistance: Double? {
        didSet {
            updateUI()
        }
    }
    
    private var averageFlights: Int? {
        didSet {
            updateUI()
        }
    }
    
    private func readActivitiesData() {
        
        guard let stepType = HKSampleType.quantityType(forIdentifier: .stepCount),
            let distanceType = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning),
            let flightType = HKSampleType.quantityType(forIdentifier: .flightsClimbed) else {
                
                print("Something horrible has happened.")
                return
        }
        
        let calendar = Calendar.current
        let currentDate = Date()
        let month = calendar.dateInterval(of: .month, for: currentDate)!
        let numOfDaysInMonth = calendar.dateComponents([.day], from: month.start, to: month.end).day!
        
        HealthKitController.sharedInstance.readPastMonthSamples(for: stepType) { (samples, error) in
            if let samples = samples, samples.count > 0 {
                
                // This is called a MapReduce operation where we apply a map to every element of a collection and then reduce them into a single value.
                let samplesInt = samples.map {Int($0.quantity.doubleValue(for: HKUnit.count()))}
                let sampleSum = samplesInt.reduce(0, {$0 + $1})
                
                // Once we have the sum from MapReduce, we can calculate the average.
                self.averageSteps = sampleSum/numOfDaysInMonth
            }
        }
        HealthKitController.sharedInstance.readPastMonthSamples(for: distanceType) { (samples, error) in
            if let samples = samples, samples.count > 0 {
                
                let samplesDouble = samples.map {$0.quantity.doubleValue(for: HKUnit.mile())}
                let sampleSum = samplesDouble.reduce(0, {$0 + $1})
                self.averageDistance = sampleSum/Double(numOfDaysInMonth)
            }
        }
        HealthKitController.sharedInstance.readPastMonthSamples(for: flightType) { (samples, error) in
            if let samples = samples, samples.count > 0 {
                
                let samplesInt = samples.map {Int($0.quantity.doubleValue(for: HKUnit.count()))}
                let sampleSum = samplesInt.reduce(0, {$0 + $1})
                self.averageFlights = sampleSum/numOfDaysInMonth
            }
        }
    }
}
