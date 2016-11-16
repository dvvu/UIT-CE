//
//  DisplayTextViewController.swift
//  UIT-CE
//
//  Created by Lee Hoa on 9/17/16.
//  Copyright © 2016 Lee Hoa. All rights reserved.
//

import UIKit

class DisplayTextViewController: UIViewController, UITextFieldDelegate {
    static let identifier = String(DisplayTextViewController)
   
    @IBOutlet weak var imageLabel: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textFieldLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var characterLabel: UILabel!
    @IBOutlet weak var allLabel: UILabel!
    @IBOutlet weak var characterImage: UIImageView!
    @IBOutlet weak var allImage: UIImageView!
    @IBOutlet weak var characterView: UIView!
    @IBOutlet weak var allView: UIView!
    @IBOutlet weak var connectStatus: UIButton!
    @IBOutlet weak var fontSize: PaddingLabel!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var pickerData:[Int] = []
    var imagesDirectoryPath:String!
    var isCharacter: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        conditionSQLite()
        self.topView.clipsToBounds = true
        self.view.clipsToBounds = true
        self.topView.addGradientWithColor(Colors.primaryBlue())
        self.view.addGradientWithColor(UIColor.whiteColor())
        self.textField.delegate = self
        onTapView()
        DataProviding.statusButton(connectStatus, status: isConnected)
        
        for i in 7...50 {
            pickerData.append(i)
        }
    }

    func onTapView() {
        self.fontSize.userInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showPickerView))
        self.fontSize.addGestureRecognizer(tapGesture)
        
        let fontGesture = UITapGestureRecognizer(target: self, action: #selector(SettingViewController.viewTapped(_:)))
        self.view.addGestureRecognizer(fontGesture)
        
        characterView.userInteractionEnabled = true
        characterImage.userInteractionEnabled = true
        characterLabel.userInteractionEnabled = true
        let tap1: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickView1))
        characterView.addGestureRecognizer(tap1)
        let tap2: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickView1))
        allImage.addGestureRecognizer(tap2)
        let tap3: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickView1))
        allLabel.addGestureRecognizer(tap3)
        
        allView.userInteractionEnabled = true
        allImage.userInteractionEnabled = true
        allLabel.userInteractionEnabled = true
        let tap4: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickView2))
        allView.addGestureRecognizer(tap4)
        let tap5: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickView2))
        allImage.addGestureRecognizer(tap5)
        let tap6: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickView2))
        allLabel.addGestureRecognizer(tap6)

    }
    
    func showPickerView() {
        self.pickerView.hidden = false
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
    
    func insertData() {
        do{
            let titles = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(imagesDirectoryPath)
            if let err = SD.executeChange("INSERT INTO ImageData (Path) VALUES (?)", withArgs: ["/\(titles[titles.count-1])"]){
                //there was an error inserting the new row, handle it here
            }
        }catch{
            print("Error")
        }
    }
    
    func clickView1() {
        if isCharacter == false {
            allImage.image = UIImage(named: "uncheck")
            characterImage.image = UIImage(named: "checked")
            isCharacter = true
        }
    }
    func clickView2() {
        if isCharacter == true {
            allImage.image = UIImage(named: "checked")
            characterImage.image = UIImage(named: "uncheck")
            isCharacter = false
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let textStr:NSString = textField.text as String!
        
        textStr.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        let textStrMutable:NSMutableString = NSMutableString(string:textStr)
        
        if string == "" {
            if textStr.length > 0 {
                textStrMutable.deleteCharactersInRange(NSMakeRange(textStrMutable.length - 1, 1))
            }

        }else{
            if string != " " {
                textStrMutable.appendString(string)
            }
        }
        
        let trimmedString:NSString = textStrMutable.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet()
        )
        print("|",trimmedString,"|")
        self.textFieldLabel.text = trimmedString as String
        let image = UIImage.imageWithLabel(textFieldLabel)
        self.imageLabel.image = image
        if trimmedString.length < 1 {
           // searchBtn.enabled = false
        }else{
           // searchBtn.enabled = true
        }
        return true
        
    }
    
    func viewTapped(sender: UITapGestureRecognizer? = nil) {
        if let tf = textField {
            tf.resignFirstResponder()
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case textField:
            textField.becomeFirstResponder()
            //password.becomeFirstResponder()
            textField.resignFirstResponder()
        // TODO: handle login here
        default:
            textField.resignFirstResponder()
        }
        return true;
    }

    /*Action Button*/
    @IBAction func saveButton(sender: AnyObject) {
        let refreshAlert = UIAlertController(title: "Comfirm", message: "Would you like to save image?", preferredStyle: UIAlertControllerStyle.Alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            
            let image = UIImage.imageWithLabel(self.textFieldLabel)
            var imagePath = NSDate().description
            imagePath = imagePath.stringByReplacingOccurrencesOfString(" ", withString: "")
            imagePath = self.imagesDirectoryPath.stringByAppendingString("/\(imagePath).png")
            let data = UIImagePNGRepresentation(image)
            let success = NSFileManager.defaultManager().createFileAtPath(imagePath, contents: data, attributes: nil)
            self.insertData()
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        
        presentViewController(refreshAlert, animated: true, completion: nil)
        
    }
    
    @IBAction func leftMenuButton(sender: AnyObject) {
        self.openLeft()
    }
    
    @IBAction func detailButton(sender: AnyObject) {
        let image = UIImage.imageWithLabel(self.textFieldLabel)
        var imagePath = NSDate().description
        imagePath = imagePath.stringByReplacingOccurrencesOfString(" ", withString: "")
        imagePath = self.imagesDirectoryPath.stringByAppendingString("/\(imagePath).png")
        let data = UIImagePNGRepresentation(image)
        let success = NSFileManager.defaultManager().createFileAtPath(imagePath, contents: data, attributes: nil)
    
        do{
            let titles = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(imagesDirectoryPath)
            if let vc = UIStoryboard.detailViewController() {
                vc.imageURL = "/"+String(UTF8String: titles[titles.count-1])!
                self.presentViewController(vc, animated: true, completion: nil)
                
                /*Remove in directory when user don't save*/
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(imagesDirectoryPath + "/"+String(UTF8String: titles[titles.count-1])!)
                    print("old image has been removed")
                } catch {
                    print("an error during a removing")
                }
            }
            
        }catch{
            print("Error")
        }
        
    }

    @IBAction func connectButton(sender: AnyObject) {
        
    }

}

extension DisplayTextViewController : UIPickerViewDataSource,UIPickerViewDelegate {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row].description
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.fontSize.text = pickerData[row].description
//        textFieldLabel.font.fontWithSize(CGFloat(pickerData[row]))
        textFieldLabel.font = textFieldLabel.font.fontWithSize(CGFloat(pickerData[row]))
        pickerView.hidden = true
    }
    
//    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
//        let pickerLabel = UILabel()
//        let titleData = pickerData[row]
////        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 30)!,NSForegroundColorAttributeName:UIColor.blackColor()])
////        pickerLabel.attributedText = myTitle
//        let hue = CGFloat(row)/CGFloat(pickerData.count)
//        pickerLabel.backgroundColor = UIColor(hue: hue, saturation: 1.0, brightness:1.0, alpha: 1.0)
//        pickerLabel.textAlignment = .Center
//        return pickerLabel
//    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 25
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 60
    }
}

