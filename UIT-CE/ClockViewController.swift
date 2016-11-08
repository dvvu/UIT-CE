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
    
    var pixels = [DataProviding.PixelData()]
    let black = DataProviding.PixelData(a: 255, r: 0, g: 0, b: 0)
    let white = DataProviding.PixelData(a: 255, r: 255, g: 255, b: 255)
    
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
    }
    
    @IBAction func choiceButton(sender: AnyObject) {
        if choiceStatus.on {
            labelStatus.text = "Analog"
        } else {
            labelStatus.text = "Digital"
        }
    }
    
    @IBAction func captureButton(sender: AnyObject) {
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
        image.image = DataProviding.imageFromARGB32Bitmap(pixels, width: 192, height: result.height)
    }
}

extension ClockViewController: BEMAnalogClockDelegate {
    @objc(currentTimeOnClock:Hours:Minutes:Seconds:)
    func currentTimeOnClock(clock: BEMAnalogClockView!, hours: String!, minutes: String!, seconds: String!) {
        
        self.timeLabel.text = "Time: "+hours+":"+minutes+":"+seconds
    }
}


