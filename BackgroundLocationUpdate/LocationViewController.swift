//
//  LocationViewController.swift
//  BackgroundLocationUpdate
//
//  Created by Michael Borgmann on 18/12/15.
//  Copyright © 2015 Michael Borgmann. All rights reserved.
//

import UIKit

class LocationViewController: UIViewController {
    
    @IBOutlet weak var modeSeg: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var savedProfile = NSMutableDictionary()
    var locations = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadData()
    }
    
    func reloadData() {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let document = paths[0] + "/" + "LocationArray.plist"
        if let savedProfile = NSMutableDictionary(contentsOfFile: document) {
        
            if savedProfile.count > 0 {
                locations = (savedProfile.objectForKey("LocationArray")?.sortedArrayUsingDescriptors([NSSortDescriptor(key: "Time", ascending: false)]))!
                if modeSeg.selectedSegmentIndex == 1 {
                    let temp = [].mutableCopy() as! NSMutableArray
                    for dic in locations {
                        if (dic.objectForKey("Accuracy") != nil){
                            temp.addObject(dic)
                        }
                    }
                    locations = temp
                }
            }
            tableView.reloadData()
        }
    }
    
    @IBAction func modeDidChanged(sender: UISegmentedControl) {
        reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        
        let dic = locations.objectAtIndex(indexPath.row)
        let state = "App State: \((dic["AppState"] as! String).stringByReplacingOccurrencesOfString("UIApplicationState", withString: ""))"
        let date = dic["Time"] as! NSDate
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        let time = dateFormatter.stringFromDate(date)
        
        if (dic.objectForKey("Accuracy") != nil) {
            let accuracy = "Accuracy: \(dic["Accuracy"] as! Double)"
            let location = "Location:" + String(format: "%.6f", (dic["Latitude"] as! Double)) + ", " + String(format: "%.6f", (dic["Longitude"] as! Double))
            
            let addFromResume = "Add From Resume: " + ((dic.objectForKey("AddFromResume") as! NSString).boolValue ? "YES" : "NO")
            cell?.textLabel?.text = "\(state)\n\(addFromResume)\n\(accuracy)\n\(location)\n\(time)"
        } else if (dic.objectForKey("Resume") != nil) {
            let resume = dic["Resume"]
            cell?.textLabel?.text = "\(state)\n\(resume)\n\(time)"
        } else {
            let appstate = dic["applicationStatus"] as! String
            cell?.textLabel!.text = "\(state)\n\(appstate)\n\(time)"
        }
        return cell!
    }
}