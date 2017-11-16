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
2) *Read user's steps, walking distance, and flights climbed during the past month, then calculate his or her daily average activities. (optional challenge)*

Note that, since **part 1** and **part 2** will cover most of what you need to know about HealthKit, **part 3** is an optional challenge. If you have time, I encourage you to try it out! It's fun and you'll get to practice the skills you just learned.

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

#### 7. Create the function `askForHealthKitAccess` in `ViewController`

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

Now that we've created a robust custom interface for HealthKit, let's start working on actually getting user's weight and height data and calculating his or her BMI (body mass index).

Let's start by creating a few private varaibles to store the user data we'll fetch.

#### 1. Import `HealthKit` and Create varaibles `weight`, `height`, and `bodyMassIndex`

Add this to the top of our `ViewController.swift` file:

``` swift 
import HealthKit
```

Add the following code to our `ViewController` class:

``` swift
    private var weight: Double? = nil {
        didSet {
        // for later
        }
    }
    
    private var height: Double? = nil {
        didSet {
        // for later
        }
    }
    
    private var bodyMassIndex: Double? = nil {
        didSet {
        // for alter
        }
    }
```
- In case you are not familar with `didSet`, it's what's called an observer. It will be run everytime the varaible is set, which we will implement later.

#### 2. Create the function `readWeightAndHeight`

We'll write a function that read user's weight and height using the functions we've created in part 1. Add the following code to your `ViewController` class:

``` swift
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
    }
```

- Here, we first make two `HKSampleType` objects indicating the type of data we want to read. The first `guard` statement should never fail.
- Then, we use our own function `readMostRecentSample()` to read the most recent data point for each of the two types. Note that in the completion handlers, we extract the numerical quantity from the result samples and store them in the varaibles we just created.

#### 3. Create the function `saveUserData`

This is the function that saves user's inputed weight and height, and his or her computed BMI into `HealthStore`

Put the following code in your `ViewController` class. It's a big function, but don't worry:

``` swift
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
```

- Inside this function, the first thing we do is check that we actually have the values that we want to store.
- Then we prepare three `HKQuantity` objects, `weightQuantity`, `heightQuantity`, and `bodyMassIndexQuantity`, which we will save to `HealthStore`.
- Because we're saving three different values and each saving operation has its own completion handler, we create the local flag `errorOccured` to keep track of whether or not any of the saving operations has failed.
- Finally, we use our `writeSample()` function to save the three values, update the flag `errorOccured`, and inform the user of the result of our saving operations at the end of the function.

#### 4. Implement IBActions

Now that we have the appropriate values and functions, let's update our IBActions:

``` swift
    @IBAction func weightTextFieldEdited(_ sender: Any) {
        guard let newText = weightTextField.text, let newWeight = Double(newText) else {
            return
        }
        weight = newWeight
    }
    
    @IBAction func heightTextFieldEdited(_ sender: Any) {
        guard let newText = heightTextField.text, let newHeight = Double(newText) else {
            return
        }
        height = newHeight
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        saveUserData()
    }
```
- Say, if HealthKit does not have user's weight and height data, or that the user wants to update his or her information,   `weightTextFieldEdited` and `heightTextFieldEdited` will be called when the respective textField has been edited. And we want to update our varaibles to hold the user's new input values.
- Naturally, we want to call our `saveUserData()` function when the save button is pressed.

#### 5. Update `askForHealthKitAccess()`

Let's call `readWeightAndHeight()` in that `else` clause in the `askForHealthKitAccess()` function so that right after authorization, we begin loading the data. Update the following code:

``` swift
    private func askForHealthKitAccess() {
        
        HealthKitController.sharedInstance.authorizeHealthKit { (sucess, error) in
            if !sucess, let error = error {
                self.showAlert(title: "HealthKit Authentication Failed", message: error.localizedDescription)
            } else {
                self.readWeightAndHeight()
            }
        }
    }
```
#### 6. Create the functions `updateUI()` and `CalculateBMI()`

Let's add some useful helper functions that help us update UI and calculate BMI:

``` swift
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
```

- In `updateUI()`, we check whether or not we've obtained the values we want and update the UI accordingly. Note that this must be explicitly done in the main thread, since it's possible to be called from any thread.
- In `CalculateBMI`, we simply do some unit conversion and calculate the BMI value.

#### 7. Update `didSet` and `readWeightAndHeight`

The time has come! Let's fill in those `didSet` observers of our private varaibles:

``` swift
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
```

- Now, everytime the `weight` or `height` is set, we recalculate `bodyMassIndex`. And everytime `bodyMassIndex` is set, we update the UI to display it to the user.

Don't forget to also add `updateUI()` to the end of our `readWeightAndHeight()` function, so that once we've fetched user's data from `HealthStore` we can display them to the user:

``` swift
    private func readWeightAndHeight() {
    
        ...
        ...    
        HealthKitController.sharedInstance.readMostRecentSample(for: weightType) { (sample, error) in
            if let sample = sample {
                self.weight = sample.quantity.doubleValue(for: HKUnit.pound())
            }
        }
        updateUI()
    }
```

#### 8. Subclass `UITextFieldDelegate` and implement `textFieldShouldReturn()`

You may notice that once the keyboard has poped up, it never goes away! This is a problem, and we solve it by making our class the delegate of both of our TextFields.

Add the following code at the very bottom of the `ViewController.swift` file:

``` swift
extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
```

- This tells the textField that once "*return*" is pressed, it should resign the keyboard.

Don't forget to also actually set the delegates! Update `viewDidLoad()` with the following code:

``` swift
    override func viewDidLoad() {
        super.viewDidLoad()
        askForHealthKitAccess()
        weightTextField.delegate = self // todo
        heightTextField.delegate = self // todo
    }
```

Good job! 

Now run your app in a simulator or on your iPhone. If you see a "*Health Access*" page pop up, click on "*Turn All Categories On*" and then "*Allow*". Walala. You've created a functional app with HealthKit support! Play around with it and once you feel ready, try out part 3!

### Part III: Calculating Average Activities *(Optional Challenge)*

In this part, we will read three types of user data, walking/running distance, and flights climbed, during the entire past month from `HealthStore`. Then we will calculate the user's daily average steps, daily average distance (in miles), and daily average flights, and update the UI to display their values.

Try to do this by yourself first! Then, once you've made a fair attempt, take a look at the solution below:

#### 1. Create the function `readPastMonthSamples()` in `HealthKitController`

Since we're querying a collection of data points over a long interval of time, we can no longer use our `readMostRecentSample()` function. 

Add the following codes to our `HealthKitController` class:

``` swift
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
```

- How is this different from the previous function for querying a single data point? Try to spot the differences!

#### 2. Create varaibles `averageSteps`, `averageDistance`, `averageFlights` and Update `updateUI()`

Add the following code to our `HealthKitController` class:

``` swift
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
```

Don't forget to also update our UpdateUI() function to set the labels:

``` swift
    private func updateUI() {
        
        DispatchQueue.main.async {
            ...
            ...
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
```

#### 3. Create the function `readActivitiesData()`

And of course, we'll need a function to read the actual data and compute their averages.

Add the following function to our `HealthKitController` class:

``` swift
    private func readActivitiesData() {
        
        guard let stepType = HKSampleType.quantityType(forIdentifier: .stepCount),
              let distanceType = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning),
              let flightType = HKSampleType.quantityType(forIdentifier: .flightsClimbed) else {
                
                print("Something horrible has happened.")
                return
        }
        HealthKitController.sharedInstance.readPastMonthSamples(for: stepType) { (samples, error) in
            if let samples = samples, samples.count > 0 {
                
                // This is called a map-reduce operation where we apply a map to every element of a collection and then reduce them into a single value.
                let samplesInt = samples.map {Int($0.quantity.doubleValue(for: HKUnit.count()))}
                let sampleSum = samplesInt.reduce(0, {$0 + $1})
                
                // Once we have the sum from map-reduce, we can calculate the average.
                self.averageSteps = sampleSum/30
            }
        }
        HealthKitController.sharedInstance.readPastMonthSamples(for: distanceType) { (samples, error) in
            if let samples = samples, samples.count > 0 {
                
                let samplesDouble = samples.map {$0.quantity.doubleValue(for: HKUnit.mile())}
                let sampleSum = samplesDouble.reduce(0, {$0 + $1})
                self.averageDistance = sampleSum/30.0
            }
        }
        HealthKitController.sharedInstance.readPastMonthSamples(for: flightType) { (samples, error) in
            if let samples = samples, samples.count > 0 {
                
                let samplesInt = samples.map {Int($0.quantity.doubleValue(for: HKUnit.count()))}
                let sampleSum = samplesInt.reduce(0, {$0 + $1})
                self.averageFlights = sampleSum/30
            }
        }
    }
```

- This function is pretty similar to `readWeightAndHeight()`. The main difference is that in each completion handler, we take the collection of data points (`samples`) and apply map-reduce to compute its average.

Lastly, don't forget to actually call the function! 

Update `askForHealthKitAccess()` to add `readActivitiesData()` to the `else` clause:

``` swift
    private func askForHealthKitAccess() {
        
        HealthKitController.sharedInstance.authorizeHealthKit { (sucess, error) in
            if !sucess, let error = error {
                self.showAlert(title: "HealthKit Authentication Failed", message: error.localizedDescription)
            } else {
                self.readWeightAndHeight()
                self.readActivitiesData()
            }
        }
    }
```

And that's it! You've finished the whole tutorial. Congratulations, you are now a semi-expert in HealthKit.

You're welcome to check out the completed version of the project in the branch `complete_project`.

---

Thank you so much for reading. - Steven
