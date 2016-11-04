//
//  DataProviding.swift
//  UIT-CE
//
//  Created by Lee Hoa on 10/23/16.
//  Copyright © 2016 Lee Hoa. All rights reserved.
//

import Foundation
import UIKit

class DataProviding {
    
    static func createAttributedString(fullString: String, fullStringColor: UIColor, subString: String, subStringColor: UIColor) -> NSMutableAttributedString
    {
        let range = (fullString as NSString).rangeOfString(subString)
        let attributedString = NSMutableAttributedString(string:fullString)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: fullStringColor, range: NSRange(location: 0, length: fullString.characters.count))
        attributedString.addAttribute(NSForegroundColorAttributeName, value: subStringColor, range: range)
        return attributedString
    }
    
    static func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    static func blackAndWhiteImage(image: UIImage) -> UIImage {
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
    
    static func intensityValuesFromImage(image: UIImage?) -> (pixelValues: [UInt8]?, width: Int, height: Int) {
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
    
    static func intensityValuesFromImage1(image: UIImage?, value: UInt8) -> (pixelValues: [UInt8]?, width: Int, height: Int) {
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
            if pixelValues![i] < value {
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
    
    struct PixelData {
        var a: UInt8 = 0
        var r: UInt8 = 0
        var g: UInt8 = 0
        var b: UInt8 = 0
    }
    
    static func imageFromARGB32Bitmap(pixels:[PixelData], width: Int, height: Int)-> UIImage {
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo:CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)
        let bitsPerComponent = 8
        let bitsPerPixel = 32
        
        // assert(pixels.count == width * height)
        
        var data = pixels // Copy to mutable []
        let providerRef = CGDataProviderCreateWithCFData(
            NSData(bytes: &data, length: data.count * sizeof(PixelData))
        )
        
        let cgim = CGImageCreate(
            width,
            height,
            bitsPerComponent,
            bitsPerPixel,
            width * Int(sizeof(PixelData)),
            rgbColorSpace,
            bitmapInfo,
            providerRef,
            nil,
            true,
            .RenderingIntentDefault
        )
        return UIImage(CGImage: cgim!)
    }
    
    static func takeSnapshotOfView(view: UIView) -> UIImage {
        UIGraphicsBeginImageContext(CGSizeMake(view.frame.size.width, view.frame.size.height))
        view.drawViewHierarchyInRect(CGRectMake(0, 0, view.frame.size.width, view.frame.size.height), afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

}