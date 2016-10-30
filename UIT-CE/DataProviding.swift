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
}