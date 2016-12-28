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
    var vanNumber: Int = 192
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getVanNumber() 
        self.view.clipsToBounds = true
        self.view.backgroundColor = Colors.primaryGray()//addGradientWithColor(UIColor.whiteColor())
        self.myClock.realTime = true
        self.myClock.currentTime = true
        self.myClock.setClockToCurrentTimeAnimated(true)
        // Do any additional setup after loading the view.
        self.myClock.delegate = self
        self.myClock.startRealTime()
        DataProviding.statusButton(connectStatus, status: isConnected)
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
        } else {
            StopTimer()
        }
    }
    
    func StartTimer() {
//        myTimer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(ClockViewController.updateTimer), userInfo: nil, repeats: true)
//        if isConnected == true {
//            isStart = false
////            myTimer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(ClockViewController.updateTimer), userInfo: nil, repeats: true)
//            self.view.makeToast(message: "Sending")
//        } else {
//            isStart = true
//            let refreshAlert = UIAlertController(title: "Failed", message: "Sorry, Please connect to Server and try again!", preferredStyle: UIAlertControllerStyle.Alert)
//            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
//            }))
//            presentViewController(refreshAlert, animated: true, completion: nil)
//        }
        updateTimer()
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
            let image2 = DataProviding.resizeImage(image1,newWidth: CGFloat(vanNumber))
            let result = DataProviding.intensityValuesFromImage2(image2, value: UInt8(valueThreshold))
            for i in 0..<Int((result.data?.count)!) {
                if result.data![i] == 1 {
                    pixels.append(white)
                } else {
                    pixels.append(black)
                }
            }
//            let newString = (result.data?.description)!
//            let data = newString.stringByReplacingOccurrencesOfString(", ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
//            let data2 = data.stringByReplacingOccurrencesOfString("[", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
//            let data3 = data2.stringByReplacingOccurrencesOfString("]", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)

            if isConnected == true {
                isStart = false
//                for k in 0..<data3.characters.count/self.vanNumber {
//                    socketTCP?.send(str: data3[k*self.vanNumber...k*self.vanNumber+self.vanNumber-1] + "\n")
//                }
                
                let height = (result.pixelValues!.count)/(valueVanNumber/8)
                var Array: [[UInt8]] = [[]]
                
                for j in 0..<height {
                    var dataArray: [UInt8] = []
                    dataArray = [UInt8](count: (valueVanNumber/8), repeatedValue: 0)
                    for i in 0...7 {
                        dataArray[i] = result.pixelValues![i + (height - 1 - j)*(valueVanNumber/8)]
                    }
                    Array.append(dataArray)
                }
                
                for a in Array {
                    DataProviding.sendData(a)
                    usleep(UInt32(valueRowDelay)*1000)
                }
                
                
                self.view.makeToast(message: "Sending")
                myTimer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(ClockViewController.updateTimer), userInfo: nil, repeats: true)
            } else {
                isStart = true
                let refreshAlert = UIAlertController(title: "Failed", message: "Sorry, Please connect to Server and try again!", preferredStyle: UIAlertControllerStyle.Alert)
                refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
                }))
                StopTimer()
                presentViewController(refreshAlert, animated: true, completion: nil)
            }
            
//            for k in 0..<data3.characters.count/self.vanNumber {
//                socketTCP?.send(str: data3[k*self.vanNumber...k*self.vanNumber+self.vanNumber-1] + "\n")
//            }
            
            image.image = DataProviding.imageFromARGB32Bitmap(pixels, width: vanNumber, height: result.height)
        }
    }
    
    func getVanNumber() {
        let (resultSet, err) = SD.executeQuery("SELECT * FROM Setting")
        if err != nil {
            print(" Error in loading Data")
        } else {
            vanNumber = (resultSet[0]["Van"]?.asInt())!
        }

    }
       
}

extension ClockViewController: BEMAnalogClockDelegate {
    @objc(currentTimeOnClock:Hours:Minutes:Seconds:)
    func currentTimeOnClock(clock: BEMAnalogClockView!, hours: String!, minutes: String!, seconds: String!) {
        if Int(hours) <= 9 {
            rHours = "0" + hours
        } else {
            rHours = hours
        }
        if Int(minutes) <= 9 {
            rMinutes = "0" + minutes
        } else {
            rMinutes = minutes
        }
        if Int(seconds) <= 9 {
            rSeconds = "0" + seconds
        } else {
            rSeconds = seconds
        }
        self.timeLabel.text = "Time: "+rHours+":"+rMinutes+":"+rSeconds
    }
}


