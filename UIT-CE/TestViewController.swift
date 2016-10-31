//
//  SettingViewController.swift
//  UIT-CE
//
//  Created by Lee Hoa on 9/20/16.
//  Copyright © 2016 Lee Hoa. All rights reserved.
//

import UIKit
import SnapKit
import NXDrawKit
import RSKImageCropper
import AVFoundation
import MobileCoreServices

class TestViewController: UIViewController {
    static let identifier = String(TestViewController)
    
    @IBOutlet weak var testLabel: UILabel!
    @IBOutlet weak var imageSta: UIImageView!
    @IBOutlet weak var imageRes: UIImageView!
    @IBAction func leftMenuButton(sender: AnyObject) {
        self.openLeft()
    }
    
    @IBAction func saveButton(sender: AnyObject) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageRes.image = DataProviding.resizeImage(imageSta.image!,newWidth: 192)
        imageRes.image = DataProviding.blackAndWhiteImage(imageRes.image!)
        DataProviding.intensityValuesFromImage(imageRes.image)
    }
    
}






