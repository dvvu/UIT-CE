//
//  SettingViewController.swift
//  UIT-CE
//
//  Created by Lee Hoa on 9/30/16.
//  Copyright © 2016 Lee Hoa. All rights reserved.
//

import UIKit
import SocketIO

class SettingViewController: UIViewController {
    static let identifier = String(SettingViewController)
   
    @IBOutlet weak var picketView: UIPickerView!
    @IBOutlet weak var vanNumber: PaddingLabel!
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var textField3: UITextField!
    @IBOutlet weak var textField4: UITextField!
    @IBOutlet weak var textField5: UITextField!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var onOff: UIButton!
    @IBOutlet weak var connecTitle: UIButton!
    
    var textField: UITextField?
    var pickerData = ["192","128", "96", "64", "32"]
    var indicator:ProgressIndicator?
    var url: String?
    var addr: String = "192.168.0.125"
    var port: Int = 4000
    var isConnection: Bool?
    
    @IBAction func leftMenuButton(sender: AnyObject) {
        self.openLeft()
    }
    
    @IBAction func onOffView(sender: AnyObject) {
        if self.onOff.titleLabel?.text == "ON" {
            self.onOff.setTitle("OFF", forState: .Normal)
            self.viewContent.userInteractionEnabled = false
            picketView.hidden = true
        } else {
            self.onOff.setTitle("ON", forState: .Normal)
            self.viewContent.userInteractionEnabled = true
        }
    }
    
    @IBAction func applyButton(sender: AnyObject) {
        
        let (resultSet, err) = SD.executeQuery("SELECT * FROM Setting")
        if err != nil {
        } else {
            print(vanNumber.text)
            let van =  Int(vanNumber.text!)
            let dRow = Int(textField1.text!)
            let dImage = Int(textField2.text!)
            let value = Int(textField3.text!)
            let iP = textField4.text!
            let port = Int(textField5.text!)
            
            if van > 0 && dRow > 0 && dImage > 0 && value > 0 && iP != "" && port > 0 {
                SD.executeQuery("UPDATE Setting SET Van = '\(van!.description)',DRow = '\(dRow!.description)', DImage = '\(dImage!.description)', Value = '\(value!.description)', IP = '\(iP)', Port = '\(port!.description)'")
            }
            
            valueVanNumber = van!
            valueThreshold = value!
            valueRowDelay = dRow!
            
            switch valueVanNumber {
            case 192:
                sizeBytes = 0x18
            case 128:
                sizeBytes = 0x10
            case 96:
                sizeBytes = 0x0C
            case 64:
                sizeBytes = 0x08
            case 32:
                sizeBytes = 0x04
            default:
                sizeBytes = 0x08
            }
        }
        
        let refreshAlert = UIAlertController(title: "Infomation", message: "Setting is changed.", preferredStyle: UIAlertControllerStyle.Alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
        }))
        
        presentViewController(refreshAlert, animated: true, completion: nil)
    }
    
    @IBAction func defaultButton(sender: AnyObject) {
        SD.executeQuery("UPDATE Setting SET Van = '192',DRow = '200', DImage = '1000', Value = '127', IP = '192.168.0.1', Port = '8080'")
        vanNumber.text = "192"
        textField1.text = "200"
        textField2.text = "1000"
        textField3.text = "127"
        textField4.text = "192.168.0.1"
        textField5.text = "8080"
    }
    
    @IBAction func connectButton(sender: AnyObject) {
        
        if isConnection == true {
            indicator!.start()
            self.connecTitle.setTitle("Connect", forState: .Normal)
            self.view.makeToast(message: "DisConnected", duration: 1.0, position: HRToastPositionCenter, image: UIImage(named: "off")!)
            socketTCP = TCPClient(addr: "1", port: 0)
            let (success, msg )=socketTCP!.connect(timeout: 1)
            if success == false {
                isConnected = success
                isConnection = isConnected
            }
            indicator!.stop()
        } else {
            indicator!.start()
           
            let (resultSet, err) = SD.executeQuery("SELECT * FROM Setting")
            if err != nil {
                print(" Error in loading Data")
            } else {
                addr =  (resultSet[0]["IP"]?.asString()!)!
                port = (resultSet[0]["Port"]?.asInt()!)!
            }
            socketTCP = TCPClient(addr: addr, port: port)
            // Connect the socket
            let (success, msg )=socketTCP!.connect(timeout: 1)
            if success == true {
                self.view.makeToast(message: "Connected", duration: 1.0, position: HRToastPositionCenter, image: UIImage(named: "on")!)
                self.connecTitle.setTitle("DisConnect", forState: .Normal)
                isConnected = success
                isConnection = isConnected
            }
            self.indicator!.stop()
        }
        
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        isConnection = isConnected
        if isConnected == true {
            self.connecTitle.setTitle("DisConnect", forState: .Normal)
        } else {
            self.connecTitle.setTitle("Connect", forState: .Normal)
        }
        
        self.topView.clipsToBounds = true
        self.view.clipsToBounds = true
        self.topView.backgroundColor = Colors.primaryTopGray()//addGradientWithColor(Colors.primaryBlue())
        self.view.backgroundColor = Colors.primaryGray()//addGradientWithColor(UIColor.whiteColor())
        
//        loaddingSetting()
        indicator = ProgressIndicator(inview:self.view,loadingViewColor: UIColor.grayColor(), indicatorColor: UIColor.blackColor(), msg: "Connecting...")
        self.view.addSubview(indicator!)
        
        picketView.dataSource = self
        picketView.delegate = self
        vanNumber.layer.borderColor = UIColor.darkGrayColor().CGColor
        vanNumber.layer.borderWidth = 1.1
        vanNumber.layer.cornerRadius = 5.0
        picketView.hidden = true
        tapTextView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SettingViewController.viewTapped(_:)))
        self.view.addGestureRecognizer(tapGesture)
        borderText(textField1)
        borderText(textField2)
        borderText(textField3)
        borderText(textField4)
        borderText(textField5)
        
        let (resultSet, err) = SD.executeQuery("SELECT * FROM Setting")
        if err != nil {
            print(" Error in loading Data")
        } else {
            print(resultSet.count)
            vanNumber.text = resultSet[0]["Van"]?.asInt()?.description
            textField1.text = resultSet[0]["DRow"]?.asInt()?.description
            textField2.text = resultSet[0]["DImage"]?.asInt()?.description
            textField3.text = resultSet[0]["Value"]?.asInt()?.description
            textField4.text = resultSet[0]["IP"]?.asString()
            textField5.text = resultSet[0]["Port"]?.asInt()?.description
        }
    }
    
//    func loaddingSetting() {
//        url = "http://"
//        let (resultSet, err) = SD.executeQuery("SELECT * FROM Setting")
//        if err != nil {
//            print(" Error in loading Data")
//        } else {
//            url =  url! + (resultSet[0]["IP"]?.asString())! + ":"
//            url = url! + (resultSet[0]["Port"]?.asInt()?.description)!
//        }
//        print(url)
//    }
    
    func borderText(textField: UITextField) {
        textField.layer.borderWidth = 1.1
        textField.layer.cornerRadius = 5.0
        textField.layer.borderColor = UIColor.blueColor().CGColor
    }
    
    func tapTextView() {
        vanNumber.userInteractionEnabled = true
        let tapOnImage: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapLabel))
        vanNumber.addGestureRecognizer(tapOnImage)
    }
    
    func tapLabel() {
        picketView.hidden = false
        if let tf = textField {
            tf.resignFirstResponder()
        }
    }
    
    func viewTapped(sender: UITapGestureRecognizer? = nil) {
        if let tf = textField {
            tf.resignFirstResponder()
            self.picketView.hidden = true
        }
    }
    
    func keyboardShown(notification: NSNotification) {
        let info = notification.userInfo!
        let value = info[UIKeyboardFrameEndUserInfoKey]!
        let rawFrame = value.CGRectValue()
        let keyboarFrame = view.convertRect(rawFrame, fromView: nil)
        if let tf = textField {
//            if container.frame.height - keyboarFrame.size.height < tf.frame.maxY {
//                container.setContentOffset(CGPointMake(0, keyboarFrame.size.height - (container.frame.height - tf.frame.maxY)), animated: true)
//            }
        }
    }
    
  }

extension SettingViewController : UIPickerViewDataSource,UIPickerViewDelegate {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        vanNumber.text = pickerData[row]
        print(pickerData[row])
        picketView.hidden = true
    }
 
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        let titleData = pickerData[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 30)!,NSForegroundColorAttributeName:UIColor.blackColor()])
        pickerLabel.attributedText = myTitle
        let hue = CGFloat(row)/CGFloat(pickerData.count)
        pickerLabel.backgroundColor = UIColor(hue: hue, saturation: 1.0, brightness:1.0, alpha: 1.0)
        pickerLabel.textAlignment = .Center
        return pickerLabel
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 25
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 60
    }
}

extension SettingViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        self.textField = textField
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let textStr:NSString = textField.text as String!
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        
        if textField == textField1 {
            setBackground(4,newLength: newLength,textStr: textStr as String, string: string)
            return newLength <= 4
        } else if textField == textField2 {
            setBackground(4,newLength: newLength,textStr: textStr as String, string: string)
            return newLength <= 4
        } else if textField == textField3{
            setBackground(3,newLength: newLength,textStr: textStr as String, string: string)
            return newLength <= 3
        } else if textField == textField4{
            setBackground(15,newLength: newLength,textStr: textStr as String, string: string)
            return newLength <= 15
        } else {
            setBackground(4,newLength: newLength,textStr: textStr as String, string: string)
            return newLength <= 4
        }
    }
    
    func setBackground(length: Int, newLength: Int, textStr: NSString, string: String) {
        if newLength <= length {
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
        }
    }

    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case textField1:
            textField2.becomeFirstResponder()
        case textField2:
            textField3.becomeFirstResponder()
        case textField3:
            textField4.becomeFirstResponder()
        case textField4:
            textField5.becomeFirstResponder()
        case textField5:
            //password.becomeFirstResponder()
            textField.resignFirstResponder()
        // TODO: handle login here
        default:
            textField.resignFirstResponder()
        }
        return true;
    }
}
