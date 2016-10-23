//
//  KDRearrangeableCollectionViewCell.swift
//  KDRearrangeableCollectionViewFlowLayout
//
//  Created by Michael Michailidis on 16/03/2015.
//  Copyright (c) 2015 Karmadust. All rights reserved.
//

import UIKit

class KDRearrangeableCollectionViewCell: UICollectionViewCell {
    
   
    @IBOutlet weak var backgroundImage: UIImageView!
    
    var baseBackgroundColor : UIColor?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    var dragging : Bool = false {

        didSet {
            
            if dragging == true {
                
                self.baseBackgroundColor = self.backgroundColor
                self.backgroundColor = UIColor.redColor()
                
            } else {
                
                self.backgroundColor = self.baseBackgroundColor
                
            }
        }
    }
    
}
