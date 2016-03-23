//
//  AppDelegate.swift
//  BackgroundLocationUpdate
//
//  Created by Michael Borgmann on 17/12/15.
//  Copyright © 2015 Michael Borgmann. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var shareModel: LocationManager!


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        NSLog("didFinishLaunchingWithOptions")
        
        shareModel = LocationManager.sharedModel
        shareModel.afterResume = false
        shareModel.addApplicationStatusToPList("didFinishLaunchingWithOptions")
        
        if UIApplication.sharedApplication().backgroundRefreshStatus == UIBackgroundRefreshStatus.Restricted {
            let alert = UIAlertController(title: "", message: "The functions of this app are limited because the Background App Refresh is disabled.", preferredStyle: .Alert)
        } else {
            NSLog("UIApplicationLaunchOptionsKey: \(launchOptions?[UIApplicationLaunchOptionsLocationKey])")
            if let options = launchOptions?[UIApplicationLaunchOptionsLocationKey] {
                shareModel.afterResume = true
                shareModel.startMonitoringLocation()
            }
        }
        
        return true
    }

    func applicationDidEnterBackground(application: UIApplication) {
        NSLog("applicationDidEnterBackground")
        shareModel.restartMonitoringLocation()
        shareModel.addApplicationStatusToPList("applicationDidEnterBackground")
    }

    func applicationDidBecomeActive(application: UIApplication) {
        NSLog("applicationDidBecomeActive")
        shareModel.addApplicationStatusToPList("applicationDidBecomeActive")
        shareModel.afterResume = false
        shareModel.startMonitoringLocation()
    }

    func applicationWillTerminate(application: UIApplication) {
        NSLog("applicationWillTerminate")
        shareModel.addApplicationStatusToPList("applicationWillTerminate")
    }

}

