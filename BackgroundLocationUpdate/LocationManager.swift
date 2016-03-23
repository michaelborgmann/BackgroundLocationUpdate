//
//  LocationManager.swift
//  BackgroundLocationUpdate
//
//  Created by Michael Borgmann on 17/12/15.
//  Copyright © 2015 Michael Borgmann. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class LocationManager : NSObject, CLLocationManagerDelegate {
    static let sharedModel = LocationManager()
    var afterResume: Bool!
    var locationDictInPList = NSMutableDictionary()
    var locationArrayInPList = NSMutableArray()
    var locationManager: CLLocationManager? = nil
    var location: CLLocationCoordinate2D!
    var accuracy: CLLocationAccuracy!
    
    func sharedManager() -> AnyObject {
        struct Static {
            static var sharedMyModel : AnyObject?
            static var onceToken : dispatch_once_t = 0
        }
        dispatch_once(&Static.onceToken) {
            Static.sharedMyModel = LocationManager()
        }
        return Static.sharedMyModel!
    }
    
    func addApplicationStatusToPList(applicationStatus: String) {
        NSLog("addApplicationStatusToPList")
        let state = appState()
        locationDictInPList.setObject(applicationStatus, forKey: "applicationStatus")
        locationDictInPList.setObject(state, forKey: "AppState")
        locationDictInPList.setObject(NSDate(), forKey: "Time")
        saveLocationsToPList()
    }
    
    func addLocationToPList(fromResume: Bool) {
        NSLog("addLocationToPList")
        let state = appState()
        locationDictInPList.setObject(NSNumber(double: location.latitude), forKey: "Latitude")
        locationDictInPList.setObject(NSNumber(double: location.longitude), forKey: "Longitude")
        locationDictInPList.setObject(NSNumber(double: accuracy), forKey: "Accuracy")
        locationDictInPList.setObject(state, forKey: "AppState")
        
        if fromResume {
            locationDictInPList.setObject("true", forKey: "AddFromResume")
        } else {
            locationDictInPList.setObject("false", forKey: "AddFromResume")
        }
        
        locationDictInPList.setObject(NSDate(), forKey: "Time")
        saveLocationsToPList()
    }
    
    func addResumeLocationToPList() {
        NSLog("addResumeLocationToPList")
        let state = appState()
        locationDictInPList.setObject("UIApplicationLaunchOptionsLocationKey", forKey: "Resume")
        locationDictInPList.setObject(state, forKey: "AppState")
        locationDictInPList.setObject(NSDate(), forKey: "Time")
        saveLocationsToPList()
    }
    
    private func appState() -> String {
        let app = UIApplication.sharedApplication()
        print(app.applicationState)
        switch app.applicationState {
        case UIApplicationState.Active: return "UIApplicationStateActive"
        case UIApplicationState.Background: return "UIApplicationStateBackground"
        case UIApplicationState.Inactive: return "UIApplicationStateInactive"
        }
    }

    private func saveLocationsToPList() {
        let plist = "LocationArray.plist"
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let document = paths[0] + "/" + plist
        var savedProfile = NSMutableDictionary(contentsOfFile: document)
        
        if savedProfile?.count > 0 {
            locationArrayInPList = savedProfile!.objectForKey("LocationArray") as! NSMutableArray
        } else {
            savedProfile = NSMutableDictionary()
            locationArrayInPList = NSMutableArray()
        }
        
        if locationDictInPList.count > 0 {
            locationArrayInPList.addObject(locationDictInPList)
            savedProfile?.setObject(locationArrayInPList, forKey: "LocationArray")
        }
        
        if savedProfile?.writeToFile(document, atomically: false) == false {
            NSLog("Couldn't save LocationArray.plist")
        }
    }
    
    func startMonitoringLocation() {
        if locationManager == nil {
            locationManager?.stopMonitoringSignificantLocationChanges()
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager?.activityType = CLActivityType.OtherNavigation
            locationManager?.requestAlwaysAuthorization()
            locationManager?.startMonitoringSignificantLocationChanges()
        }
    }
    
    func restartMonitoringLocation() {
        locationManager?.stopMonitoringSignificantLocationChanges()
        locationManager?.requestAlwaysAuthorization()
        locationManager?.startMonitoringSignificantLocationChanges()
    }
 
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        NSLog("locationmanager didUpdateLocations: \(locations)")
        for index in 0..<locations.count {
            let newLocation = locations[index]
            let location = newLocation.coordinate
            let accuracy = newLocation.horizontalAccuracy
            self.location = location
            self.accuracy = accuracy
        }
        addLocationToPList(afterResume)
    }
    

}