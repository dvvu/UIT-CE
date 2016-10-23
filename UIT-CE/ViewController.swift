//
//  ViewController.swift
//  UIT-CE
//
//  Created by Lee Hoa on 8/14/16.
//  Copyright © 2016 Lee Hoa. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    static let identifier = String(ViewController)
    @IBOutlet weak var randomImage: UIImageView!
    @IBOutlet var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var viewMain: UIView!

    var actionButton: ActionButton!
    var imagePicker = UIImagePickerController()
    var left: LeftMenuViewController?
    var startPoint: Int = 1
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)        
       // SD.deleteTable("Setting")
        createTable()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // self.view1.clipsToBounds = true
        self.view2.clipsToBounds = true
        self.viewMain.clipsToBounds = true
        //self.view1.addGradientWithColor(UIColor.grayColor())
        self.view2.addGradientWithColor(UIColor.grayColor())
        self.viewMain.addGradientWithColor(UIColor.darkGrayColor())
    }
    
    func createTable() {
        
        /*Table image*/
        if let err = SD.createTable("SampleImageTable", withColumnNamesAndTypes: ["Name": .StringVal, "Image": .UIImageVal]) {
            print("Error: Do it again!")
        } else {
            let image = UIImage(named:"ic1")
            if let imageID = SD.saveUIImage(image!) {
                if let err = SD.executeChange("INSERT INTO SampleImageTable (Name, Image) VALUES (?, ?)", withArgs: ["ic1", imageID]) {
                    //there was an error inserting the new row, handle it here
                }
            }
        }
        
        /*Table setting*/
        if let err = SD.createTable("Setting", withColumnNamesAndTypes: ["Van": .IntVal, "DRow": .IntVal, "DImage": .IntVal, "Value": .IntVal, "IP": .StringVal, "Port": .IntVal]) {
            print("Error: Do it again!")
        } else {
            if let err = SD.executeChange("INSERT INTO Setting (Van, DRow, DImage, Value, IP, Port) VALUES (?, ?, ?, ?, ?, ?)", withArgs: [168,500,1000,127,"192.168.1.1",90]) {
            }
        }
    }

    
    func floatingMenu() {
        /*add brower for SQLite*/
        let twitterImage = UIImage(named: "clock_ic")!
        let twitter = ActionButtonItem(title: "Brower", image: twitterImage)
        twitter.action = { item in print("Path into forder")
            
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .SavedPhotosAlbum
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
            self.imagePicker.delegate = self
        }
        
        /*add show picture*/
        let plusImage1 = UIImage(named: "clock_ic")!
        let drawNew = ActionButtonItem(title: "Draw picture", image: plusImage1)
        drawNew.action = { item in
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc: UIViewController = storyboard.instantiateViewControllerWithIdentifier("UITDrawViewController") as! UITDrawViewController
            self.presentViewController(vc, animated: true, completion: nil)
        }
        
        actionButton = ActionButton(attachedToView: self.view, items: [twitter,drawNew])
        actionButton.action = { button in button.toggleMenu() }
        actionButton.setTitle("+", forState: .Normal)
        actionButton.backgroundColor = UIColor(red: 238.0/255.0, green: 130.0/255.0, blue: 34.0/255.0, alpha:1.0)
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!) {
        let selectedImage : UIImage = image
        print(selectedImage)
    }
    
    static func loadLeftMenu() -> SlideMenuController {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let mainController = mainStoryboard.instantiateViewControllerWithIdentifier(ViewController.identifier)
        let letfMenu = mainStoryboard.instantiateViewControllerWithIdentifier(LeftMenuViewController.identifier)
        return SlideMenuController(mainViewController: mainController, leftMenuViewController: letfMenu)
    }

    @IBAction func leftMenuButton(sender: AnyObject) {
        self.openLeft()
    }
    
    @IBAction func RamdomButton(sender: AnyObject) {
        var timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "updateImage", userInfo: nil, repeats: true)
    }
    
    func updateImage() {
        if startPoint < 5 {
            dispatch_async(dispatch_get_main_queue()) {
                let im:String = "a"+self.startPoint.description
                self.randomImage.image = UIImage(named:  im)
                self.view.layoutIfNeeded()
                self.startPoint = self.startPoint + 1
            }
        } else {
            startPoint = 1
        }
    }
    
}

