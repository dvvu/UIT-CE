//
//  LeftMenuCell.swift
//  UIT-CE
//
//  Created by Lee Hoa on 9/10/16.
//  Copyright © 2016 Lee Hoa. All rights reserved.
//

import UIKit

class LeftMenuCell: UICollectionViewCell {

    @IBOutlet weak var titleLebel: UILabel!
    @IBOutlet weak var pictureImage: UIImageView!
    var delegate: PageDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
