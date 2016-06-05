//
//  FilterViewCell.swift
//  Filterer
//
//  Created by Kong Kim Yuan on 6/6/16.
//  Copyright © 2016 UofT. All rights reserved.
//

import UIKit

class FilterViewCell : UICollectionViewCell {
    
    @IBOutlet weak var filterButton: UIButton!
    
    var filterCell: FilterCell?
    
    
    @IBAction func onButtonTap(sender: UIButton) {
        if let fc = filterCell {
            print(String(fc.filter))
        } else {
            print("Button pressed")
        }
    }
    
}
