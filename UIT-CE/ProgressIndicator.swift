//
//  ProgressIndicator.swift
//  UIT-CE
//
//  Created by Lee Hoa on 10/25/16.
//  Copyright © 2016 Lee Hoa. All rights reserved.
//

import Foundation

import UIKit
import Foundation

class ProgressIndicator: UIView {
    
    var indicatorColor:UIColor
    var loadingViewColor:UIColor
    var loadingMessage:String
    var messageFrame = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    init(inview:UIView,loadingViewColor:UIColor,indicatorColor:UIColor,msg:String){
        
        self.indicatorColor = indicatorColor
        self.loadingViewColor = loadingViewColor
        self.loadingMessage = msg
        super.init(frame: CGRectMake(inview.frame.midX - 150, inview.frame.midY - 25 , 300, 50))
        initalizeCustomIndicator()
        
    }
    convenience init(inview:UIView) {
        
        self.init(inview: inview,loadingViewColor: UIColor.brownColor(),indicatorColor:UIColor.blackColor(), msg: "Loading..")
    }
    convenience init(inview:UIView,messsage:String) {
        
        self.init(inview: inview,loadingViewColor: UIColor.brownColor(),indicatorColor:UIColor.blackColor(), msg: messsage)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    func initalizeCustomIndicator(){
        
        messageFrame.frame = self.bounds
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        activityIndicator.tintColor = indicatorColor
        activityIndicator.hidesWhenStopped = true
        activityIndicator.frame = CGRect(x: self.bounds.origin.x + 6, y: 0, width: 20, height: 50)
        print(activityIndicator.frame)
        let strLabel = UILabel(frame:CGRect(x: self.bounds.origin.x + 30, y: 0, width: self.bounds.width - (self.bounds.origin.x + 30) , height: 50))
        strLabel.text = loadingMessage
        strLabel.adjustsFontSizeToFitWidth = true
        strLabel.textColor = UIColor.whiteColor()
        messageFrame.layer.cornerRadius = 15
        messageFrame.backgroundColor = loadingViewColor
        messageFrame.alpha = 0.8
        messageFrame.addSubview(activityIndicator)
        messageFrame.addSubview(strLabel)
        
        
    }
    
    func  start(){
        //check if view is already there or not..if again started
        if !self.subviews.contains(messageFrame){
            
            activityIndicator.startAnimating()
            self.addSubview(messageFrame)
            
        }
    }
    
    func stop(){
        
        if self.subviews.contains(messageFrame){
            
            activityIndicator.stopAnimating()
            messageFrame.removeFromSuperview()
            
        }
    }
}