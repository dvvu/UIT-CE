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
    
    static func statusConnection(connectStatus : UIButton) -> Bool {
        if socket?.status != nil {
            switch socket!.status {
            case .Connected:
                connectStatus.setImage(UIImage(named: "on"), forState: .Normal)
                print("status: connected")
                return true
            case .Connecting:
                print("status: connecting")
                return false
            case .Disconnected:
                connectStatus.setImage(UIImage(named: "off"), forState: .Normal)
                print("status: disconnected")
                return false
            case .NotConnected:
                connectStatus.setImage(UIImage(named: "off"), forState: .Normal)
                print("status: notconnected")
                return false
            }
        } else {
            connectStatus.setImage(UIImage(named: "off"), forState: .Normal)
            return false
        }
    }
    
    static func statusButton(connectStatus : UIButton, status: Bool) {
        if status == true {
            connectStatus.setImage(UIImage(named: "on"), forState: .Normal)
        } else {
            connectStatus.setImage(UIImage(named: "off"), forState: .Normal)
        }
    }
    
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
        let newHeight = CGFloat(image.size.height) * scale
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
        
        return (pixelValues, width, height)
    }
    
    static func intensityValuesFromImage2(image: UIImage?, value: UInt8) -> (data: [UInt8]?, pixelValues: [UInt8]?, width: Int, height: Int) {
        var width = 0
        var height = 0
        var pixelValues: [UInt8]?
        var pixelValues1: [UInt8]?
        if (image != nil) {
            let imageRef = image!.CGImage
            width = CGImageGetWidth(imageRef)
            height = CGImageGetHeight(imageRef)
            
            let bytesPerPixel = 1
           
            let bytesPerRow = bytesPerPixel * width
            let bitsPerComponent = 8
            let totalBytes = width * height * bytesPerPixel
            
            let colorSpace = CGColorSpaceCreateDeviceGray()
            pixelValues = [UInt8](count: totalBytes, repeatedValue: 0)
            
            pixelValues1 = [UInt8](count: (width * height)/8, repeatedValue: 0)
            
            let contextRef = CGBitmapContextCreate(&pixelValues!, width, height, bitsPerComponent, bytesPerRow, colorSpace, 0)
            CGContextDrawImage(contextRef, CGRectMake(0.0, 0.0, CGFloat(width), CGFloat(height)), imageRef)
        }
        
        for i in 0..<Int((pixelValues?.count)!) {
            
            let byteIndex = i >> 3; // devide by 8
            let bitShift = i & 7;   // i modulo 8
            
            if pixelValues![i] < value {
                pixelValues![i] = 0
                let mask: UInt8 = (0x01 << UInt8(bitShift))
                pixelValues1![byteIndex] = pixelValues1![byteIndex] | mask
            } else {
                pixelValues![i] = 1
                
                let mask: UInt8 = (~(0x01 << UInt8(bitShift)))// (0xFE << bitShift);
                pixelValues1![byteIndex] = (pixelValues1![byteIndex] & mask)
            }
        }
        
        return (pixelValues,pixelValues1, width, height)
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
    
    
    static  func sendMessage(data: String){
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            let request = self.sendRequest(data, client: socketTCP)
            print("received message: \(request)")
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                print("This is run on the main queue, after the previous code in outer block")
            })
            
        })
    }
    
    static  func sendRequest(data: String, client: TCPClient?) -> (String?) {
        // It use ufter connection
        if client != nil {
            // Send data  (WE MUST ADD SENDING MESSAGE '\n' )
            let (isSuccess, errorMessage) = client!.send(str: "\(data)\n")
            if isSuccess {
                // Read response data
                let data = client!.read(1024*10)
                if let d = data {
                    // Create String from response data
                    if let str = NSString(bytes: d, length: d.count, encoding: NSUTF8StringEncoding) as? String {
                        return (data: str)
                    } else {
                        return (data: nil)
                    }
                } else {
                    return (data: nil)
                }
            } else {
                print(errorMessage)
                return (data: nil)
            }
        } else {
            return (data: nil)
        }
    }
    
    
    static let start : [UInt8] = [0x40, 0x00]
    static let chksm: [UInt8] = [0x00, 0x00]
    static let begin: [UInt8] = [0x42, 0x00]
    static var size : [UInt8] = [0x00, sizeBytes] //8 byte
    
    static func sendData(foo : [UInt8]) {
        
        switch valueVanNumber {
        case 192:
            size = [0x00, 0x18]
        case 128:
            size = [0x00, 0x10]
        case 96:
            size = [0x00, 0x0C]
        case 64:
            size = [0x00, 0x08]
        case 32:
            size = [0x00, 0x04]
        default:
            size = [0x00, 0x08]
        }
        
        socketTCP?.send(data: start)
        socketTCP?.send(data: chksm)
        socketTCP?.send(data: begin)
        socketTCP?.send(data: size)
        // usleep(1) // co
        socketTCP?.send(data: foo)
        socketTCP?.send(data: chksm)
    }

}