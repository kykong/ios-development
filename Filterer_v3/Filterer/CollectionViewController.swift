//
//  CollectionViewController.swift
//  Filterer
//
//  Created by Kong Kim Yuan on 6/6/16.
//  Copyright © 2016 UofT. All rights reserved.
//

import UIKit

class CollectionViewController : UICollectionViewController {
    
    @IBOutlet weak var cell: UICollectionViewCell!
    @IBOutlet weak var cellButton: UIButton!
    
    let filterCells: [FilterCell] = [
        FilterCell(filter: ColourIntensityFilter(colour: .Red), imageName: "red_filter"),
        FilterCell(filter: ColourIntensityFilter(colour: .Green), imageName: "green_filter"),
        FilterCell(filter: ColourIntensityFilter(colour: .Blue), imageName: "blue_filter"),
        FilterCell(filter: SepiaFilter(), imageName: "sepia_filter"),
        FilterCell(filter: ContrastFilter(), imageName: "contrast_filter"),
        FilterCell(filter: LuminosityGreyscaleFilter(), imageName: "lumigrey_filter")
    ]
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterCells.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let fc = filterCellForIndexPath(indexPath)
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FilterCell", forIndexPath: indexPath) as! FilterViewCell
        cell.filterButton.setImage(fc.image, forState: .Normal)
        cell.filterCell = fc
        cell.backgroundColor = UIColor.whiteColor()
        return cell
    }
    
    func filterCellForIndexPath(indexPath: NSIndexPath) -> FilterCell {
        return filterCells[indexPath.row]
    }
    
}



struct FilterCell {
    let filter : FilterType
    let image : UIImage
    
    init(filter : FilterType, imageName : String) {
        self.filter = filter
        self.image = UIImage.init(named: imageName)!
    }
}