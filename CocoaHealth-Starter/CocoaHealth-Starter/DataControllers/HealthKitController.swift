//
//  HealthKitController.swift
//  CocoaHealth-Starter
//
//  Created by Steven Shang on 11/16/17.
//  Copyright © 2017 cocoanuts. All rights reserved.
//

import UIKit
import HealthKit

class HealthKitController: NSObject {
    
    // MARK: Part I: Interfacing with HealthKit API
    
    static let sharedInstance = HealthKitController()
    
    private enum HealthKitControllerError: Error {
        case DeviceNotSupported
        case DataTypeNotAvailable
    }
    
    private let healthStore = HKHealthStore()
    
    func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Void) {
        
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HealthKitControllerError.DeviceNotSupported)
            return
        }
        
        guard let weight = HKObjectType.quantityType(forIdentifier: .bodyMass),
            let height = HKObjectType.quantityType(forIdentifier: .height),
            let bodyMassIndex = HKObjectType.quantityType(forIdentifier: .bodyMassIndex),
            let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount),
            let distance = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning),
            let flightCount = HKObjectType.quantityType(forIdentifier: .flightsClimbed) else {
                
                completion(false, HealthKitControllerError.DataTypeNotAvailable)
                return
        }
        
        let dataToWrite: Set<HKSampleType> = [weight,
                                              height,
                                              bodyMassIndex]
        
        let dataToRead: Set<HKSampleType> = [weight,
                                             height,
                                             stepCount,
                                             distance,
                                             flightCount]
        
        healthStore.requestAuthorization(toShare: dataToWrite, read: dataToRead) { (success, error) in
            completion(success, error)
        }
    }
    
    func readMostRecentSample(for type: HKSampleType, completion: @escaping (HKQuantitySample?, Error?) -> Void) {
        
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        let mostRecentSortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let sampleQuery = HKSampleQuery(sampleType: type, predicate: predicate, limit: 1, sortDescriptors: [mostRecentSortDescriptor]) { (query, result, error) in
            
            DispatchQueue.main.async {
                guard let samples = result as? [HKQuantitySample], let sample = samples.first else {
                    completion(nil, error)
                    return
                }
                completion(sample, nil)
            }
        }
        
        healthStore.execute(sampleQuery)
    }
    
    func writeSample(for quantityType: HKQuantityType, sampleQuantity: HKQuantity, completion: @escaping (Bool, Error?) -> Void) {
        
        let sample = HKQuantitySample(type: quantityType, quantity: sampleQuantity, start: Date(), end: Date())
        healthStore.save(sample) { (sucess, error) in
            DispatchQueue.main.async {
                completion(sucess, error)
            }
        }
    }
    
    // MARK: Part III: Calculating Average Activities
    
    func readPastMonthSamples(for type: HKSampleType, completion: @escaping ([HKQuantitySample]?, Error?) -> Void) {
        
        let today = Date()
        guard let aMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: today) else {
            print("The universe was created less than a month ago.")
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: aMonthAgo, end: today, options: .strictStartDate)
        let mostRecentSortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let sampleQuery = HKSampleQuery(sampleType: type, predicate: predicate, limit: 0, sortDescriptors: [mostRecentSortDescriptor]) { (query, result, error) in
            
            DispatchQueue.main.async {
                guard let samples = result as? [HKQuantitySample] else {
                    completion(nil, error)
                    return
                }
                completion(samples, nil)
            }
        }
        
        healthStore.execute(sampleQuery)
    }
}
