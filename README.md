# HealthKit Demo

This is a [CocoaNuts](https://sites.google.com/site/cocoanutsios/home) demo developed by [sstevenshang](https://github.com/sstevenshang).

## HealthKit Overview

[HealthKit](https://developer.apple.com/documentation/healthkit), what is it?

<img src="https://cdn.macrumors.com/article-new/2014/09/healthkit-logo.png" width="200"/>

It is a simple framework for managing health-related data across apps on iPhone and Apple Watch. If you are developing a health & fitness app, HealthKit allows you to accesss, store, and share various types of user data like weight, blood pressure, steps, or workout informations in an encrpted database called `HealthStore`

Note that HealthKit also allow you to directly work with some hardware devices. For example, "*in iOS 8.0, the system can automatically save data from compatible Bluetooth LE heart rate monitors.*" (from Apple)

## CocoaHealth: a Demo App

In this demo, we'll use HealthKit to create the following two functionalities:

1) Reading user's height, weight, and monthly steps/distance/flights from `HealthStore`
2) Writing user's height, weight, and body mass index to `HealthStore`

### Part I: Interfacing with HealthKit API

```swift
import HealthKit
```

### Part II: Calculating BMI

### Part III: Calculating Average Activities *(Optional)*
