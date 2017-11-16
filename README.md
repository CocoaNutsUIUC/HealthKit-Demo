# HealthKit Demo

This is a [CocoaNuts](https://sites.google.com/site/cocoanutsios/home) demo developed by [sstevenshang](https://github.com/sstevenshang).

## HealthKit Overview

[HealthKit](https://developer.apple.com/documentation/healthkit), what is it?

<img src="https://cdn.macrumors.com/article-new/2014/09/healthkit-logo.png" width="200"/>

It is a simple framework for managing health-related data across apps on iPhone and Apple Watch. If you are developing a health & fitness app, HealthKit allows you to accesss, store, and share various types of user data like weight, blood pressure, steps, or workout informations in an encrpted database called `HealthStore`.

Note that HealthKit also allow you to directly work with some hardware devices. For example, "*in iOS 8.0, the system can automatically save data from compatible Bluetooth LE heart rate monitors.*" (from Apple)

## CocoaHealth: a Demo App

### Introduction

In this demo app, you will learn the basics of HealthKit querying and storing. 

The app, once finished, will look something like this:

<img src="https://github.com/sstevenshang/HealthKit-Demo/blob/master/screenshot_3.png" width="275"/> <img src="https://github.com/sstevenshang/HealthKit-Demo/blob/master/screenshot_1.png" width="275"/> <img src="https://github.com/sstevenshang/HealthKit-Demo/blob/master/screenshot_2.png" width="275"/>

It has two main functionalities:

1) *Read user's height and weight from `HealthStore` or have user input it, calculate his or her body mass index, and store them back into `HealthStore`.*
2) *Read user's steps, walking distance, and flights climbed during the past month, then calculate his or her daily average activities.*

### Getting Started

To avoid wasting too much time on UI/storyboard setup, I've prepared a starter project for you. In it, I've set up the minimal UI elements in stoyboard and connected them to IBOutlets and IBActions. So unless you *want* to tweak the design, you don't need to touch `Main.storyboard` once during this entire tutorial.

To get started, download the starter project in this repository by clicking on "*Clone or download*" on the top of the page and then "*Download ZIP*".

Once you have the folder downloaded and unzipped, go ahead and open "*CocoaHealth-Starter.xcodeproj*". Then the first thing you wanna do is team signing, as you would do in any project. ***Go to the Project Navigator and selection a team under "General".*** (If you have trouble signing a team, please raise your hand, and we'll come around to help you.)

Then, you wanna ***click on "Capacities" and toggle the option that says "HealthKit".*** This will create the entitlements you need to be able to use framework.

![toggling-101](https://koenig-media.raywenderlich.com/uploads/2017/06/UpdatedCapabilities.png)

There, now you're all set to begin exploring HealthKit!

### Part I: Interfacing with HealthKit API

First, we will implement some generic read/write functions to interface with the HealKit API. Not only will this step make our life a lot easier later on, it is the absolute core of this demo! Once you've learned how to interface with the API, you can basically do anything you want with HealthKit and become ready to disrupt the healthcare industry.

Let's start by talking about **User Permissions**. 

Apple cares a lot about user's privacy. Getting the user's permissions to access his or her data is very important in any app that involves sensitive personal data, which is why we need to first update the shared usage descriptions in `info.plist` and authorize HealthKit before anything else.

#### 1. Update `info.plist`

Open `info.plist` and add the following keys: (If you scroll down in the dropbox, you'll be able to find them.)

- **Privacy – Health Share Usage Description**
- **Privacy – Health Update Usage Description**

And under the value section of each keys, put: 
- **"The app needs assess to your health information."**

Note that if these two keys are not set, the app will crash on launch when it's trying to authorize HealthKit.

#### 2. Create the new class `HealthKitController`

Think back to the principles of Model-View-Controller, we'll create a class called `HealthKitController` that handles all businesses that has to do with HealthKit's API so that when we work on other stuff, this layer of abstraction is nice and clear.

- Create a new file named "*HealthKitController.swift*", make it a subclass of `NSObject`.
- Import `HealthKit` at the top of the file.
- Create a singleton named `sharedInstance` since we will only need one instance of this class per user. A [singleton](https://en.wikipedia.org/wiki/Singleton_pattern) is just an object that is initiated exactly once and persists on a global scope.

Code:

``` swift
import UIKit
import HealthKit

class HealthKitController: NSObject {
    
    // Singleton
    static let sharedInstance = HealthKitController()
}
```

Then, let's start working on the authorization process.

#### 3. Create a `HealthKitControllerError` Enum and a `HKHealthStore` instance

Add the folowing piece of code to your `HealthKitController` class:

``` swift
    private enum HealthKitControllerError: Error {
        case DeviceNotSupported
        case DataTypeNotAvailable
    }
    
    private let healthStore = HKHealthStore()
```

The enum will be useful later when we're trying to figure out what kind of error our app is encountering. The `healthStore` varaible an instance of `HKHealthStore`, which is the database through which we'll store and query our data.

#### 4. Create the function `authorizeHealthKit()`

This is the function that will ask the user to authorize access to his or her data. Add the below function to our `HealthKitController` class:

``` swift
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
```

Woo! What a big function, but don't be scared. It's just a piece of code that tells `healthStore` which data we need to read from and which data we want to write to. Let me explain it line by line:

- First, the function takes in a `completion` handler, which is called before exiting the function. This is called a closure, which is really just a function pointer. We use it to inform whichever class that'll be calling `authorizeHealthKit()` whether or not the authorization has successed and what kind of error we've encountered.
- The first `guard` statement is to check whether HealthKit is available at all on your device! Why would it not be available? Well, if you're on an iPad.
- The second super big `guard` statement is to make sure that the data types we want to access actually exist. Your app should always know what type of data it'll be dealing with!
- Then, we created two hash sets HKSampleType `dataToWrite` and `dataToRead` which store information about which kind of data we'll write to and read from respectively.
- Finally, we call on `healthStore.requestAuthorization()` to actually ask the user for authorization.

#### 5. Create the function `readMostRecentSample`

Next, we want to write a function that will query the most up-to-date data point of one data type from `HealthStore`. We'll use it later to query the user's most recent weight and height. 

Add the following function to our `HealthKitController` class:

``` swift
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
```

- Here, because our function should be generic, we will take in the arguments `type`, which specifies which the data type we want to query, and `completion`, which returns the query result and any error back to the function-caller.
- If you've ever used `CoreData`, you'll find that a `HealthStore` query is remarkably similar to a `NSFetchedRequest`. 
- We first need to create a `predicate` specifying the time interval from which we want to query our data, then we create a `NSSortDescriptor` that specify how we want our data to be sorted, which in this case is by descending `startDate`.
- We then create the `HKSampleQuery`. Note that in among the arguments, we set `limit` to 1. This is because we only need one data point. Inside its completion closure, notice that we wrapped everything in `DispatchQueue.main.async`. This is because HealthKit functions asynchronously and we want the result to be handled in the main thread so that UI can be responsive.
- Finally, we simply call `healthStore.execute()` to actually excute the query.

#### 6. Create the function `writeSample`

Finally, we want a function that writes data back into `HealthStore`. The function is also generic, so we can use it to store any type of data. Add the below function to our `HealthKitController` class:

``` swift
    func writeSample(for quantityType: HKQuantityType, sampleQuantity: HKQuantity, completion: @escaping (Bool, Error?) -> Void) {
        
        let sample = HKQuantitySample(type: quantityType, quantity: sampleQuantity, start: Date(), end: Date())
        healthStore.save(sample) { (sucess, error) in
            DispatchQueue.main.async {
                completion(sucess, error)
            }
        }
    }
```

- We first create a `HKQuantitySample` object from our data `sampleQuantity` which is of the type `quantityType`.
- Then simply call `healthStore.save()` to save the data, and we handle the result in the main thread with our `completion` handler. Wala! That's it.

#### Create the function `askForHealthKitAccess` in `ViewController`

Lastly, let's go to "*ViewController.swift*" (you should notice all the IBOutlets and IBActions that are already in the class), and put the following function in our `ViewController` class:

``` swift
    private func askForHealthKitAccess() {
        
        HealthKitController.sharedInstance.authorizeHealthKit { (sucess, error) in
            if !sucess, let error = error {
                self.showAlert(title: "HealthKit Authentication Failed", message: error.localizedDescription)
            } else {
                // for later
            }
        }
    }
        
    private func showAlert(title: String, message: String) {
            
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
```

- In `askForHealthKitAccess()`, we call the function `authorizeHealthKit()` that we created in step 4, and we handle its error by showing an alert.
- In `showAlert`, we simply create an `UIAlertController` and inform the user of a message.

Then, last-lastly, let's call the function `askForHealthKitAccess()` in `viewDidLoad()` of our `ViewController` class:

``` swift
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        askForHealthKitAccess()
    }
```
### Part II: Calculating BMI

Now that we've created a robust HealthKit interface, let's start working on the actually getting user's weight and height data and calculating his or her BMI (body mass index).

### Part III: Calculating Average Activities *(Optional)*
