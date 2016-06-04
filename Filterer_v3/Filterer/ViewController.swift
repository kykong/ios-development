//
//  ViewController.swift
//  Filterer
//
//  Created by Jack on 2015-09-22.
//  Copyright © 2015 UofT. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var originalImage: UIImage?
    var filteredImage: UIImage?
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var crossFadeImageView: UIImageView!
    
    @IBOutlet var secondaryMenu: UIView!
    @IBOutlet var bottomMenu: UIView!
    
    @IBOutlet var filterButton: UIButton!
    @IBOutlet weak var compareButton: UIButton!
    @IBOutlet weak var labelOverlay: UILabel!
    
    var showFiltered: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        secondaryMenu.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        secondaryMenu.translatesAutoresizingMaskIntoConstraints = false
        originalImage = imageView.image
    }

    // MARK: Share
    @IBAction func onShare(sender: AnyObject) {
        let activityController = UIActivityViewController(activityItems: ["Check out our really cool app", imageView.image!], applicationActivities: nil)
        presentViewController(activityController, animated: true, completion: nil)
    }
    
    // MARK: New Photo
    @IBAction func onNewPhoto(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: .ActionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { action in
            self.showCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Album", style: .Default, handler: { action in
            self.showAlbum()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func showCamera() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .Camera
        
        presentViewController(cameraPicker, animated: true, completion: nil)
    }
    
    func showAlbum() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .PhotoLibrary
        
        presentViewController(cameraPicker, animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            originalImage = image
            imageView.image = originalImage
            filterSelected(false)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Filter Menu
    @IBAction func onFilter(sender: UIButton) {
        if (sender.selected) {
            hideSecondaryMenu()
            sender.selected = false
        } else {
            showSecondaryMenu()
            sender.selected = true
        }
    }
    
    func showSecondaryMenu() {
        view.addSubview(secondaryMenu)
        
        let bottomConstraint = secondaryMenu.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let leftConstraint = secondaryMenu.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let rightConstraint = secondaryMenu.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        
        let heightConstraint = secondaryMenu.heightAnchor.constraintEqualToConstant(44)
        
        NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        view.layoutIfNeeded()
        
        self.secondaryMenu.alpha = 0
        UIView.animateWithDuration(0.4) {
            self.secondaryMenu.alpha = 1.0
        }
    }

    func hideSecondaryMenu() {
        UIView.animateWithDuration(0.4, animations: {
            self.secondaryMenu.alpha = 0
            }) { completed in
                if completed == true {
                    self.secondaryMenu.removeFromSuperview()
                }
        }
    }

    @IBAction func onRedFilter(sender: UIButton) {
        print("Red pressed")
        //hideSecondaryMenu()
        filterSelected(true)
        
        var rgbaImage = RGBAImage(image: originalImage!)!
        
        let pixelCount = rgbaImage.width * rgbaImage.height
        
        var redTotal = 0
        
        for y in 0..<rgbaImage.height {
            for x in 0..<rgbaImage.width {
                redTotal += (Int)(rgbaImage.pixels[y * rgbaImage.width + x].red)
            }
        }
        let avgRed = redTotal / pixelCount
        
        for y in 0..<rgbaImage.height {
            for x in 0..<rgbaImage.width {
                let index = y * rgbaImage.width + x
                var pixel = rgbaImage.pixels[index]
                let redDelta = Int(pixel.red) - avgRed
                
                var modifier = 1 + 4 * (Double(y) / Double(rgbaImage.height))
                if (Int(pixel.red) < avgRed) {
                    modifier = 1
                }
                
                pixel.red = UInt8(max(min(255, Int(round(Double(avgRed) + modifier * Double(redDelta)))), 0))
                rgbaImage.pixels[index] = pixel
            }
        }
        filteredImage = rgbaImage.toUIImage()
        //imageView.image = filteredImage
        toggleImage(false)
    }
    
    
    @IBAction func onCompare(sender: UIButton) {
        toggleImage(showFiltered)
    }
    
    
    func filterSelected(selected : Bool) {
        compareButton.enabled = selected
        showFiltered = selected
        labelOverlay.hidden = selected
    }
    
    func toggleImage(original: Bool) {
        if (original) {
            crossFadeImageView.image = filteredImage
            crossFadeImageView.alpha = 1.0
            
            imageView.image = originalImage
            //imageView.alpha = 0
            showFiltered = false
            
        } else {
            crossFadeImageView.image = originalImage
            crossFadeImageView.alpha = 1.0
            
            imageView.image = filteredImage
            //imageView.alpha = 0
            showFiltered = true
        }
        UIView.animateWithDuration(0.4, animations: {
            self.crossFadeImageView.alpha = 0
            //self.imageView.alpha = 1
        })
        
        labelOverlay.hidden = showFiltered
        
    }
    


    
    @IBAction func handleLongPress(sender: UILongPressGestureRecognizer) {
        if (!compareButton.enabled) { return }
        
        if sender.state == .Began {
            toggleImage(showFiltered)
            
        } else if sender.state == .Ended {
            toggleImage(showFiltered)
        }
    }
    
}

