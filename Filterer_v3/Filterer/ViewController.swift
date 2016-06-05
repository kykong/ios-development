//
//  ViewController.swift
//  Filterer
//
//  Created by Jack on 2015-09-22.
//  Copyright © 2015 UofT. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var crossFadeImageView: UIImageView!
    
    @IBOutlet var secondaryMenu: UIView!
    @IBOutlet var sliderPanel: UIView!
    @IBOutlet var bottomMenu: UIView!
    
    @IBOutlet var filterButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var compareButton: UIButton!
    @IBOutlet weak var labelOverlay: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var slider: UISlider!
    
    var originalImage: UIImage?
    var filteredImage: UIImage?
    var currentImage: UIImage?
    var showFiltered: Bool = false
    var currentFilter: FilterType?
    
    
    // Filters
    var redFilter: FilterType? = nil
    var greenFilter: FilterType? = nil
    var blueFilter: FilterType? = nil
    var sepiaFilter: FilterType? = nil
    var contrastFilter: FilterType? = nil
    var lumiGreyFilter: FilterType? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        secondaryMenu.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        secondaryMenu.translatesAutoresizingMaskIntoConstraints = false
        sliderPanel.translatesAutoresizingMaskIntoConstraints = false
        originalImage = imageView.image
        setupFilters()
    }

    
    func setupFilters() {
        redFilter = ColourIntensityFilter(colour: .Red)
        greenFilter = ColourIntensityFilter(colour: .Green)
        blueFilter = ColourIntensityFilter(colour: .Blue)
        sepiaFilter = SepiaFilter()
        contrastFilter = ContrastFilter()
        lumiGreyFilter = LuminosityGreyscaleFilter()
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
            displayImage(originalImage!)
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

        } else {
            showSecondaryMenu()
        }
    }
    
    func showSecondaryMenu() {
        if editButton.selected { hideSlider() }
        filterButton.selected = true

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
        filterButton.selected = false
        UIView.animateWithDuration(0.4, animations: {
            self.secondaryMenu.alpha = 0
            }) { completed in
                if completed == true {
                    self.secondaryMenu.removeFromSuperview()
                }
        }
    }
    
    
    func showSlider() {
        if (filterButton.selected) { hideSecondaryMenu() }
        editButton.selected = true
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        slider.value = 0.5
        
        if let filter = currentFilter {
            slider.minimumValue = Float(filter.intensityMinMax[0])
            slider.maximumValue = Float(filter.intensityMinMax[1])
            slider.value = Float(filter.intensity)
        }
        
        view.addSubview(sliderPanel)
        let bottomConstraint = sliderPanel.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let leftConstraint = sliderPanel.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let rightConstraint = sliderPanel.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        let heightConstraint = sliderPanel.heightAnchor.constraintEqualToConstant(46)
        
        NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        view.layoutIfNeeded()
        
        self.sliderPanel.alpha = 0
        UIView.animateWithDuration(0.4) {
            self.sliderPanel.alpha = 1.0
        }
        
    }
    
    func hideSlider() {
        editButton.selected = false
        UIView.animateWithDuration(0.4, animations: {
            self.sliderPanel.alpha = 0
            }) { completed in
                if completed == true {
                    self.sliderPanel.removeFromSuperview()
                }
        }
    }
    
    
    
    func displayImage(img: UIImage) {
        imageView.image = img
        currentImage = img
    }
    

    @IBAction func onRedFilter(sender: UIButton) {
        applyFilter(redFilter!)
    }
    
    @IBAction func onGreenFilter(sender: UIButton) {
        applyFilter(greenFilter!)
    }
    
    @IBAction func onBlueFilter(sender: UIButton) {
        applyFilter(blueFilter!)
    }
    
    @IBAction func onSepiaFilter(sender: UIButton) {
        applyFilter(sepiaFilter!)
    }
    
    @IBAction func onContrastFilter(sender: UIButton) {
        //applyFilter(contrastFilter!)
        applyFilter(lumiGreyFilter!)
    }

    @IBAction func onEdit(sender: UIButton) {
        if sender.selected {
            hideSlider()
            
        } else {
            showSlider()
        }
    }
    
    @IBAction func onCompare(sender: UIButton) {
        toggleImage(showFiltered)
    }
    
    
    func applyFilter(filter: FilterType) {
        imageView.userInteractionEnabled = false
        activityIndicator.startAnimating()
        currentFilter = filter
        let rgbaImage = RGBAImage(image: originalImage!)!
        
        let queue = NSOperationQueue()
        queue.addOperationWithBlock() {
            self.filteredImage = filter.applyFilter(rgbaImage).toUIImage()
            
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                self.activityIndicator.stopAnimating()
                self.toggleImage(false)
                self.filterSelected(true)
                self.imageView.userInteractionEnabled = true
            }
        }
        
    }
    
    
    
    
    func filterSelected(selected : Bool) {
        compareButton.enabled = selected
        editButton.enabled = selected
        showFiltered = selected
        labelOverlay.hidden = selected
        if (!selected) {
            resetAllFilters()
            hideSlider()
        }
    }
    
    func toggleImage(original: Bool) {
        if (original) {
            crossFadeImageView.image = currentImage
            crossFadeImageView.alpha = 1.0
            displayImage(originalImage!)
            showFiltered = false
            
        } else {
            crossFadeImageView.image = currentImage
            crossFadeImageView.alpha = 1.0
            displayImage(filteredImage!)
            showFiltered = true
        }
        UIView.animateWithDuration(0.4, animations: {
            self.crossFadeImageView.alpha = 0
        })
        
        labelOverlay.hidden = showFiltered
        
    }
    
    func resetAllFilters() {
        redFilter?.reset()
        greenFilter?.reset()
        blueFilter?.reset()
        sepiaFilter?.reset()
        contrastFilter?.reset()
    }
    

    @IBAction func sliderValueUpdated(sender: UISlider) {
        if let filter = currentFilter {
            filter.setIntensity(Double(sender.value))
            applyFilter(filter)
        }
        
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

