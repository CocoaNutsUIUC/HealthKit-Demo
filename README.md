# HealthKit Demo

This is a [CocoaNuts](https://sites.google.com/site/cocoanutsios/home) demo developed by [sstevenshang](https://github.com/sstevenshang).

## HealthKit Overview

[HealthKit](https://developer.apple.com/documentation/healthkit), what is it?

<img src="https://cdn.macrumors.com/article-new/2014/09/healthkit-logo.png" width="200"/>

It is a simple framework for managing health-related data across apps on iPhone and Apple Watch. If you are developing a health & fitness app, HealthKit allows you to accesss, store, and share various types of user data like weight, blood pressure, steps, or workout informations in an encrpted database called `HealthStore`

Note that HealthKit also allow you to directly work with some hardware devices. For example, "*in iOS 8.0, the system can automatically save data from compatible Bluetooth LE heart rate monitors.*" (from Apple)

## CocoaHealth: a Demo App

To get started, download the starter project in this repository by clicking on "*Clone or download*" on the top of the page and then "*Download ZIP*".

Once you have the folder downloaded and unzipped, go ahead and open "***CocoaHealth-Starter.xcodeproj***". Then the first thing you wanna do is team signing, as you would do in any project. If you have trouble signing your team, please raise your hand, and we'll come around to help you.

### Part I: Interfacing with HealthKit API

1. 

```swift
import HealthKit
```

### Part II: Calculating BMI

### Part III: Calculating Average Activities *(Optional)*
