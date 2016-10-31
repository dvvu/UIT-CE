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
    
    @IBOutlet weak var myClock: BEMAnalogClockView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myClock.realTime = true
        myClock.hours = 5
        myClock.minutes = 42
        myClock.stopRealTime()
        myClock.currentTime = true
        myClock.setClockToCurrentTimeAnimated(false)
        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
