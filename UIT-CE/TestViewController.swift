//
//  SettingViewController.swift
//  UIT-CE
//
//  Created by Lee Hoa on 9/20/16.
//  Copyright © 2016 Lee Hoa. All rights reserved.
//

import UIKit
import SocketIO

class TestViewController: UIViewController {
    static let identifier = String(TestViewController)

    @IBOutlet weak var imageSta: UIImageView!
    @IBOutlet weak var imageRes: UIImageView!
    @IBOutlet weak var slidervalue: UISlider!
    
    var pixels = [PixelData]()
    let black = PixelData(a: 255, r: 0, g: 0, b: 0)
    let white = PixelData(a: 255, r: 255, g: 255, b: 255)
    var newString: String?
    
    @IBAction func leftMenuButton(sender: AnyObject) {
        self.openLeft()
    }
    
    @IBAction func sliderAction(sender: AnyObject) {
        let value = slidervalue.value
        imageRes.image = DataProviding.resizeImage(imageSta.image!,newWidth: 192)
        pixels = []
        let result = intensityValuesFromImage1(imageRes.image, value: UInt8(value))
        for i in 0..<Int((result.pixelValues?.count)!) {
            if result.pixelValues![i] == 1 {
                pixels.append(white)
            } else {
                pixels.append(black)
            }
        }
        imageRes.image = imageFromARGB32Bitmap(pixels, width: 192, height: result.height)
        //newString = result.pixelValues?.description
    }
    
    @IBAction func sendButton(sender: AnyObject) {
//         socket1 = SocketIOClient(socketURL: NSURL(string: "http://localhost:8080")!, config: [.log(true), .forcePolling(true)])
        let socket = SocketIOClient(socketURL: NSURL(string: "http://lees-macbook-pro.local/")!, config: [SocketIOClientOption.Log(true), SocketIOClientOption.ForcePolling(true)])
        socket.on("connect") {data, ack in
            print("socket connected")
        }
        socket.connect()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func intensityValuesFromImage1(image: UIImage?, value: UInt8) -> (pixelValues: [UInt8]?, width: Int, height: Int) {
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
    
    func imageFromARGB32Bitmap(pixels:[PixelData], width: Int, height: Int)-> UIImage {
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
    

}






