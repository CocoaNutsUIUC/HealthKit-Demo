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

- Privacy – Health Share Usage Description
- Privacy – Health Update Usage Description

And under the value section of each keys, put: 
- "The app needs assess to your health information."

Note that if these two keys are not set, the app will crash on launch when it's trying to authorize HealthKit.

#### 2. Create the new class `HealthKitController`

Think back to the principles of Model-View-Controller, we'll create a class called `HealthKitController` that handles all businesses that has to do with HealthKit's API so that when we work on other stuff, this layer of abstraction is nice and clear.

### Part II: Calculating BMI

### Part III: Calculating Average Activities *(Optional)*
