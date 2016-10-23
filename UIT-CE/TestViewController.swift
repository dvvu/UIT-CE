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
        
        
        let text = "We tried to make this app as most intuitive."
        let linkTextWithColor = "e"
        
        let range = (text as NSString).rangeOfString(linkTextWithColor)
        
        let attributedString = NSMutableAttributedString(string:text)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor() , range: range)

        testLabel.attributedText = attributedString
        
        
        
        imageRes.image = resizeImage(imageSta.image!,newWidth: 192)
        imageRes.image = blackAndWhiteImage(imageRes.image!)
        intensityValuesFromImage(imageRes.image)
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func blackAndWhiteImage(image: UIImage) -> UIImage {
        let context = CIContext(options: nil)
        let ciImage = CoreImage.CIImage(image: image)!
        
        // Set image color to b/w
        let bwFilter = CIFilter(name: "CIColorControls")!
        bwFilter.setValuesForKeysWithDictionary([kCIInputImageKey:ciImage, kCIInputBrightnessKey:NSNumber(float: 0.0), kCIInputContrastKey:NSNumber(float: 1.1), kCIInputSaturationKey:NSNumber(float: 0.0)])
        let bwFilterOutput = (bwFilter.outputImage)!
        
        // Adjust exposure
        let exposureFilter = CIFilter(name: "CIExposureAdjust")!
        exposureFilter.setValuesForKeysWithDictionary([kCIInputImageKey:bwFilterOutput, kCIInputEVKey:NSNumber(float: 0.7)])
        let exposureFilterOutput = (exposureFilter.outputImage)!
        
        // Create UIImage from context
        let bwCGIImage = context.createCGImage(exposureFilterOutput, fromRect: ciImage.extent)
        let resultImage = UIImage(CGImage: bwCGIImage, scale: 1.0, orientation: image.imageOrientation)
        
        return resultImage
    }
    
    func intensityValuesFromImage(image: UIImage?) -> (pixelValues: [UInt8]?, width: Int, height: Int)
    {
        var width = 0
        var height = 0
        var pixelValues: [UInt8]?
        if (image != nil) {
            let imageRef = image!.CGImage
            width = CGImageGetWidth(imageRef)
            height = CGImageGetHeight(imageRef)
            
            let bytesPerPixel = 1
            // let bytesPerPixel = 3
            let bytesPerRow = bytesPerPixel * width
            let bitsPerComponent = 8
            let totalBytes = width * height * bytesPerPixel
            
            let colorSpace = CGColorSpaceCreateDeviceGray()
            pixelValues = [UInt8](count: totalBytes, repeatedValue: 0)
            
            let contextRef = CGBitmapContextCreate(&pixelValues!, width, height, bitsPerComponent, bytesPerRow, colorSpace, 0)
            CGContextDrawImage(contextRef, CGRectMake(0.0, 0.0, CGFloat(width), CGFloat(height)), imageRef)
        }
        
        for i in 0..<Int((pixelValues?.count)!) {
            if pixelValues![i] < 127 {
                pixelValues![i] = 0
            } else {
                pixelValues![i] = 1
            }
        }
//        let aString: String = (pixelValues?.description)!
//        let newString = aString.stringByReplacingOccurrencesOfString(", ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
//        let string2 = newString.stringByReplacingOccurrencesOfString("0", withString: "∙", options: NSStringCompareOptions.LiteralSearch, range: nil)
//        let string3 = string2.stringByReplacingOccurrencesOfString("1", withString: "💧", options: NSStringCompareOptions.LiteralSearch, range: nil)
//        print(string3)
//        print(pixelValues?.count)
        return (pixelValues, width, height)
    }
}






