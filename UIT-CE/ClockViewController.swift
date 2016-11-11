//
//  ClockViewController.swift
//  UIT-CE
//
//  Created by Lee Hoa on 10/23/16.
//  Copyright © 2016 Lee Hoa. All rights reserved.
//

import UIKit
import BEMAnalogClock

class ClockViewController: UIViewController {
    static let identifier = String(ClockViewController)
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var myClock: BEMAnalogClockView!
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var digitalLabel: UIView!
    @IBOutlet weak var choiceStatus: UISwitch!
    @IBOutlet weak var connectStatus: UIButton!
    
    var pixels = [DataProviding.PixelData()]
    let black = DataProviding.PixelData(a: 255, r: 0, g: 0, b: 0)
    let white = DataProviding.PixelData(a: 255, r: 255, g: 255, b: 255)
    var rHours: String = ""
    var rMinutes: String = ""
    var rSeconds: String = ""
    var myTimer: NSTimer = NSTimer()
    var isStart: Bool = true
    var isConnected: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.clipsToBounds = true
        self.view.addGradientWithColor(UIColor.whiteColor())
        self.myClock.realTime = true
        self.myClock.currentTime = true
        self.myClock.setClockToCurrentTimeAnimated(true)
        // Do any additional setup after loading the view.
        self.myClock.delegate = self
        self.myClock.startRealTime()
        isConnected = DataProviding.statusConnection(connectStatus)
    }
    
    @IBAction func leftMenuButton(sender: AnyObject) {
        self.openLeft()
    }
    
    @IBAction func choiceButton(sender: AnyObject) {
        if choiceStatus.on {
            labelStatus.text = "Analog"
        } else {
            labelStatus.text = "Digital"
        }
    }
    
    @IBAction func captureButton(sender: AnyObject) {
        if isStart == true {
            StartTimer()
            isStart = false
        } else {
            StopTimer()
            isStart = true
        }
    }
    
    func StartTimer() {
        if isConnected == true {
            myTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(ClockViewController.updateTimer), userInfo: nil, repeats: true)
            self.view.makeToast(message: "Sending")
        } else {
            let refreshAlert = UIAlertController(title: "Sorry", message: "Please connect to Server and try again!", preferredStyle: UIAlertControllerStyle.Alert)
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            }))
            presentViewController(refreshAlert, animated: true, completion: nil)
        }
        
    }
    
    func StopTimer() {
        myTimer.invalidate()
        self.view.makeToast(message: "Stoped")
    }
    
    func updateTimer() {
    
        if self.isViewLoaded() && (self.view.window != nil) {
            // viewController is visible
            pixels = []
            var image1 = UIImage()
            
            if choiceStatus.on {
                image1 = DataProviding.takeSnapshotOfView(myClock)
            } else {
                image1 = DataProviding.takeSnapshotOfView(digitalLabel)
            }
            let image2 = DataProviding.resizeImage(image1,newWidth: 192)
            let result = DataProviding.intensityValuesFromImage(image2)
            for i in 0..<Int((result.pixelValues?.count)!) {
                if result.pixelValues![i] == 1 {
                    pixels.append(white)
                } else {
                    pixels.append(black)
                }
            }
            let newString = (result.pixelValues?.description)!
            let data = newString.stringByReplacingOccurrencesOfString(", ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            socket?.emit("message", data)
            image.image = DataProviding.imageFromARGB32Bitmap(pixels, width: 192, height: result.height)
        }
    }
       
}

extension ClockViewController: BEMAnalogClockDelegate {
    @objc(currentTimeOnClock:Hours:Minutes:Seconds:)
    func currentTimeOnClock(clock: BEMAnalogClockView!, hours: String!, minutes: String!, seconds: String!) {
        if Int(hours) < 9 {
            rHours = "0" + hours
        } else {
            rHours = hours
        }
        if Int(minutes) < 9 {
            rMinutes = "0" + minutes
        } else {
            rMinutes = minutes
        }
        if Int(seconds) < 9 {
            rSeconds = "0" + seconds
        } else {
            rSeconds = seconds
        }
        self.timeLabel.text = "Time: "+rHours+":"+rMinutes+":"+rSeconds
    }
}


