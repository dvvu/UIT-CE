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
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var delayTextField: UITextField!
    
    var pixels = [DataProviding.PixelData()]
    let black = DataProviding.PixelData(a: 255, r: 0, g: 0, b: 0)
    let white = DataProviding.PixelData(a: 255, r: 255, g: 255, b: 255)
    var imagesDirectoryPath:String!
    var textField: UITextField?
    var imageURL: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        conditionSQLite()
        layOutTap()
        
        let data = NSFileManager.defaultManager().contentsAtPath(imagesDirectoryPath+imageURL!)
        let image1 = UIImage(data: data!)
        let image2 = DataProviding.resizeImage(image1!, newWidth: 192)
        
        let result = DataProviding.intensityValuesFromImage(image2)
        for i in 0..<Int((result.pixelValues?.count)!) {
            if result.pixelValues![i] == 1 {
                pixels.append(white)
            } else {
                pixels.append(black)
            }
        }
        self.image.image = DataProviding.imageFromARGB32Bitmap(self.pixels, width: 192, height: result.height)
 
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {() -> Void in
            let aString: String = (result.pixelValues!.description)
            let newString = aString.stringByReplacingOccurrencesOfString(", ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            let lineNumber = newString.characters.count/192
            if lineNumber > 0 {
                for i in 1...lineNumber+1 {
                    if (192*i + i) < newString.characters.count {
                        newString.insert("\n", ind: 192*i + i)
                    }
                }
            }

            dispatch_sync(dispatch_get_main_queue(), {() -> Void in
              print(newString)
            })
        })

    }
    
    /* Button action*/
    @IBAction func backButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func sendButton(sender: AnyObject) {
        let refreshAlert = UIAlertController(title: "Sending...", message: "Please, Connect and check with wifi?", preferredStyle: UIAlertControllerStyle.Alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
        }))
        
        presentViewController(refreshAlert, animated: true, completion: nil)
        
    }
    
    @IBAction func demoButton(sender: AnyObject) {
        self.image.frame.origin.y = -self.middleView.frame.size.height
        UIView.animateWithDuration(3.0, delay: 2.0, options: [.Repeat, .CurveEaseOut], animations: {
            self.image.frame.origin.y += 2*self.middleView.frame.size.height
            }, completion: nil)
//        let refreshAlert = UIAlertController(title: "Demo", message: "Checked it again!", preferredStyle: UIAlertControllerStyle.Alert)
//        
//        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
//            
//        }))
//        
//        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction!) in
//            
//        }))
//        
//        presentViewController(refreshAlert, animated: true, completion: nil)
    }
    
    /*func*/
    
    func layOutTap() {
        self.topView.clipsToBounds = true
        self.view.clipsToBounds = true
        self.topView.addGradientWithColor(UIColor.grayColor())
        self.view.addGradientWithColor(UIColor.darkGrayColor())
        
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