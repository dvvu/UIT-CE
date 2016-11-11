//
//  DetailViewController.swift
//  UIT-CE
//
//  Created by Lee Hoa on 10/15/16.
//  Copyright © 2016 Lee Hoa. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    static let identifier = String(DetailViewController)
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var delayTextField: UITextField!
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var demoString: UIButton!
    @IBOutlet weak var sliderValue: UISlider!
    @IBOutlet weak var connectStatus: UIButton!
    var vanNumber: Int = 192
    var isConnected: Bool?
    var pixels = [DataProviding.PixelData()]
    let black = DataProviding.PixelData(a: 255, r: 0, g: 0, b: 0)
    let white = DataProviding.PixelData(a: 255, r: 255, g: 255, b: 255)
    var imagesDirectoryPath:String!
    var textField: UITextField?
    var imageURL: String?
    var image1 = UIImage()
    var image2 = UIImage()
    var isClick: Bool = true
    var data: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        conditionSQLite()
        loaddingSetting()
        layOutTap()
        
        let data = NSFileManager.defaultManager().contentsAtPath(imagesDirectoryPath+imageURL!)
         image1 = UIImage(data: data!)!
         image2 = DataProviding.resizeImage(image1, newWidth: CGFloat(vanNumber))
        let result = DataProviding.intensityValuesFromImage1(image2, value: UInt8(sliderValue.value))
        
         let newString = (result.pixelValues?.description)!
         self.data = newString.stringByReplacingOccurrencesOfString(", ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        imageLabel.font = UIFont(name:"Courier", size: 1)
        loadString()
      isConnected =  DataProviding.statusConnection(connectStatus)
    }
    
    /* Button action*/
    @IBAction func slider(sender: AnyObject) {
        loadString()
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func sendButton(sender: AnyObject) {
        if isConnected == true {
            socket!.emit("message", data)
            let refreshAlert = UIAlertController(title: "Congatulate", message: "Sent success!", preferredStyle: UIAlertControllerStyle.Alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            }))
            
            presentViewController(refreshAlert, animated: true, completion: nil)
        } else {
            let refreshAlert = UIAlertController(title: "Failed", message: "Sorry, Please connect to Server and try again!", preferredStyle: UIAlertControllerStyle.Alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            }))
            
            presentViewController(refreshAlert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func demoButton(sender: AnyObject) {
        if isClick == true {
            sliderValue.hidden = true
            self.imageLabel.frame.origin.y = -self.middleView.frame.size.height
            UIView.animateWithDuration(3.0, delay: 2.0, options: [.Repeat, .CurveEaseOut], animations: {
                self.imageLabel.frame.origin.y += 2*self.middleView.frame.size.height
                }, completion: nil)
            isClick = false
            demoString.setTitle("Stop", forState: .Normal)
        } else {
            self.imageLabel.layer.removeAllAnimations()
            sliderValue.hidden = false
            isClick = true
            demoString.setTitle("Start", forState: .Normal)
        }
    }
    
    /*func*/
    func layOutTap() {
        self.view.clipsToBounds = true
        self.topView.backgroundColor = Colors.primaryBlue()
        self.view.addGradientWithColor(UIColor.whiteColor())
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.viewTapped(_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func conditionSQLite() {
        /*Condition to have path*/
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        // Get the Document directory path
        let documentDirectorPath:String = paths[0]
        // Create a new path for the new images folder
        imagesDirectoryPath = documentDirectorPath.stringByAppendingString("/ImagePicker")
        var objcBool:ObjCBool = true
        let isExist = NSFileManager.defaultManager().fileExistsAtPath(imagesDirectoryPath, isDirectory: &objcBool)
        // If the folder with the given path doesn't exist already, create it
        if isExist == false{
            do{
                try NSFileManager.defaultManager().createDirectoryAtPath(imagesDirectoryPath, withIntermediateDirectories: true, attributes: nil)
            }catch{
                print("Something went wrong while creating a new folder")
            }
        }
    }

    func viewTapped(sender: UITapGestureRecognizer? = nil) {
        if let tf = textField {
            tf.resignFirstResponder()
        }
    }
    
    func loaddingSetting() {
        let (resultSet, err) = SD.executeQuery("SELECT * FROM Setting")
        if err != nil {
            print(" Error in loading Data")
        } else {
            vanNumber = (resultSet[0]["Van"]?.asInt())!
        }
    }
    
    func loadString() {
//        let attributedString = NSMutableAttributedString(string:"")
//        let string = "_"
//        
//        for i in 0..<string.characters.count {
//            let smallString = string.startIndex.advancedBy(i)
//            
//            let newString = DataProviding.createAttributedString(String(string[smallString]), fullStringColor: UIColor.blackColor(), subString: "_", subStringColor: UIColor.redColor())
//            
//            attributedString.appendAttributedString(newString)
//        }
        
        let result = DataProviding.intensityValuesFromImage1(image2, value: UInt8(sliderValue.value))
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {() -> Void in
            
            let aString: String = (result.pixelValues!.description)
            let newString = aString.stringByReplacingOccurrencesOfString(", ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            let newString2 = newString.stringByReplacingOccurrencesOfString("0", withString: "_", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            let aString11: NSMutableString = NSMutableString(string: newString2)
            
            let lineNumber = aString11.length/self.vanNumber
            if lineNumber > 0 {
                for i in 1...lineNumber+1 {
                    if (self.vanNumber*i + i) < aString11.length {
                        aString11.insertString("\n", atIndex: self.vanNumber*i + i)
                    }
                }
            }
            dispatch_sync(dispatch_get_main_queue(), {() -> Void in
                self.imageLabel.text = aString11 as String
            })
        })
        
    }
}

extension DetailViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        self.textField = textField
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let textStr:NSString = textField.text as String!
        guard let text = textField.text else { return true }
        var newLength = text.characters.count + string.characters.count - range.length
        
        if textField == delayTextField {
            return newLength <= 4
        } else {
            return newLength <= 0
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case delayTextField:
            textField.resignFirstResponder()
        // TODO: handle login here
        default:
            textField.resignFirstResponder()
        }
        return true;
    }
}