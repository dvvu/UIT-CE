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
    var dataSendding: [UInt8]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        conditionSQLite()
        loaddingSetting()
        layOutTap()
        
        let data = NSFileManager.defaultManager().contentsAtPath(imagesDirectoryPath+imageURL!)
         image1 = UIImage(data: data!)!
         image2 = DataProviding.resizeImage(image1, newWidth: CGFloat(valueVanNumber))
        let result = DataProviding.intensityValuesFromImage2(image2, value: UInt8(sliderValue.value))
        let newString = (result.data?.description)!
        let newString2 = newString.stringByReplacingOccurrencesOfString(", ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let newString3 = newString2.stringByReplacingOccurrencesOfString("[", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        self.data = newString3.stringByReplacingOccurrencesOfString("]", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        dataSendding = result.pixelValues
        imageLabel.font = UIFont(name:"Courier", size: 1)
        loadString(self.data)
        DataProviding.statusButton(connectStatus, status: isConnected)
    }
    
    /* Button action*/
    @IBAction func slider(sender: AnyObject) {
//        loadString()
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func sendButton(sender: AnyObject) {
       
        if isConnected == true {
//            let result1 = DataProviding.intensityValuesFromImage2(image2, value: UInt8(sliderValue.value))
            let height = (dataSendding!.count)/8
            var Array: [[UInt8]] = [[]]
            
            for j in 0..<height {
                var dataArray: [UInt8] = []
                dataArray = [UInt8](count: 8, repeatedValue: 0)
                for i in 0...7 {
                    dataArray[i] = dataSendding![i + (height - 1 - j)*8]
                }
                Array.append(dataArray)
            }
            
            for a in Array {
                DataProviding.sendData(a)
                usleep(100000)
            }
            
//            for i in 0..<data.characters.count/vanNumber {
//               // DataProviding.sendMessage(data)
//                socketTCP?.send(str: data[i*vanNumber...i*vanNumber+vanNumber-1] + "\n")
//            }
            
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
    
//    let start : [UInt8] = [0x40, 0x00]
//    let chksm: [UInt8] = [0x00, 0x00]
//    let begin: [UInt8] = [0x42, 0x00]
//    let size : [UInt8] = [0x00, 0x08] //8 byte
//    
//    func sendData(foo : [UInt8]) {
//        socketTCP?.send(data: start)
//        socketTCP?.send(data: chksm)
//        socketTCP?.send(data: begin)
//        socketTCP?.send(data: size)
//       // usleep(1) // co
//        socketTCP?.send(data: foo)
//        socketTCP?.send(data: chksm)
//    }
    
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
        self.topView.backgroundColor = Colors.primaryTopGray()
        self.view.backgroundColor = Colors.primaryGray()
        
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
            valueVanNumber = (resultSet[0]["Van"]?.asInt())!
        }
    }
    
    func loadString(aString: String) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {() -> Void in
            let newString2 = aString.stringByReplacingOccurrencesOfString("0", withString: "_", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            let aString11: NSMutableString = NSMutableString(string: newString2)
            
            let lineNumber = aString11.length/valueVanNumber
            if lineNumber > 0 {
                for i in 1...lineNumber+1 {
                    if (valueVanNumber*i + i) < aString11.length {
                        aString11.insertString("\n", atIndex: valueVanNumber*i + i)
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