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
    
    var pixels = [DataProviding.PixelData()]
    let black = DataProviding.PixelData(a: 255, r: 0, g: 0, b: 0)
    let white = DataProviding.PixelData(a: 255, r: 255, g: 255, b: 255)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.myClock.realTime = true
        self.myClock.currentTime = true
        self.myClock.setClockToCurrentTimeAnimated(true)
        // Do any additional setup after loading the view.
        self.myClock.delegate = self
        self.myClock.startRealTime()
    }
    
    @IBAction func captureButton(sender: AnyObject) {
        pixels = []
        let image1 = takeSnapshotOfView(myClock)
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
        
    func takeSnapshotOfView(view: UIView) -> UIImage {
        UIGraphicsBeginImageContext(CGSizeMake(view.frame.size.width, view.frame.size.height))
        view.drawViewHierarchyInRect(CGRectMake(0, 0, view.frame.size.width, view.frame.size.height), afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}

extension ClockViewController: BEMAnalogClockDelegate {
    @objc(currentTimeOnClock:Hours:Minutes:Seconds:)
    func currentTimeOnClock(clock: BEMAnalogClockView!, hours: String!, minutes: String!, seconds: String!) {
        
        self.timeLabel.text = "Time: "+hours+":"+minutes+":"+seconds
    }
}


