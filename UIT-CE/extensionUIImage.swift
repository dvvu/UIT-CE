
//  extensionUIImage.swift
//  UIT-CE
//
//  Created by Lee Hoa on 10/1/16.
//  Copyright © 2016 Lee Hoa. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    class func imageWithLabel(label: UILabel) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0.0)
        label.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}

extension UIView {
    func addGradientWithColor(color: UIColor) {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.frame.size.width = self.frame.size.width
        gradient.colors = [UIColor.whiteColor().CGColor, color.CGColor]
        self.layer.insertSublayer(gradient, atIndex: 0)
    }
}

extension String {
    func insert(string:String,ind:Int) -> String {
        return  String(self.characters.prefix(ind)) + string + String(self.characters.suffix(self.characters.count-ind))
    }
}