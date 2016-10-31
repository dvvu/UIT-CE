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
 
    @IBAction func saveButton(sender: AnyObject) {
        let refreshAlert = UIAlertController(title: "Comfirm", message: "Would you like to save image?", preferredStyle: UIAlertControllerStyle.Alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
           
            let image = UIImage.imageWithLabel(self.textFieldLabel)
            if let imageID = SD.saveUIImage(image) {
                if let err = SD.executeChange("INSERT INTO SampleImageTable (Name, Image) VALUES (?, ?)", withArgs: [imageID, imageID]) {
                }
            }
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        
        presentViewController(refreshAlert, animated: true, completion: nil)
        
    }
    
    @IBAction func leftMenuButton(sender: AnyObject) {
        self.openLeft()
    }
    
    @IBAction func sendButton(sender: AnyObject) {
        let refreshAlert = UIAlertController(title: "Sending...", message: "Please, Connect and check with wifi?", preferredStyle: UIAlertControllerStyle.Alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
        }))
        
        presentViewController(refreshAlert, animated: true, completion: nil)
    
    }
    
    @IBOutlet weak var characterImage: UIImageView!
    @IBOutlet weak var allImage: UIImageView!
    
    @IBOutlet weak var characterView: UIView!
    @IBOutlet weak var allView: UIView!
    var isCharacter: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.topView.clipsToBounds = true
        self.view.clipsToBounds = true
        self.topView.addGradientWithColor(UIColor.grayColor())
        self.view.addGradientWithColor(UIColor.darkGrayColor())
        self.textField.delegate = self
        self.textField.becomeFirstResponder()
        onTapView()
    }
    
    func onTapView() {        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SettingViewController.viewTapped(_:)))
        self.view.addGestureRecognizer(tapGesture)
        
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


}
