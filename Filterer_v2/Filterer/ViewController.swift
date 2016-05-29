//
//  ViewController.swift
//  Filterer
//
//  Created by Kong Kim Yuan on 21/5/16.
//  Copyright © 2016 KKY. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var filteredImage: UIImage?
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet var secondaryMenu: UIView!
    @IBOutlet weak var bottomMenu: UIView!
    
    @IBOutlet weak var filterButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        secondaryMenu.translatesAutoresizingMaskIntoConstraints = false
        secondaryMenu.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onNewPhoto(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: .ActionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .Default, handler: {action in
            self.showCamera()
        }))

        actionSheet.addAction(UIAlertAction(title: "Album", style: .Default, handler: {action in
            self.showAlbum()
        }))
    
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func showCamera() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .Camera
        self.presentViewController(cameraPicker, animated: true, completion: nil)
    }
    
    func showAlbum() {
        let albumPicker = UIImagePickerController()
        albumPicker.delegate = self
        albumPicker.sourceType = .PhotoLibrary
        self.presentViewController(albumPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)

    }
    
    
    @IBAction func onFilter(sender: UIButton) {
        if (!sender.selected) {
            showSecondaryMenu()
            
        } else {
            hideSecondaryMenu()
        }
        sender.selected = !sender.selected
    }


    @IBAction func onShare(sender: UIButton) {
        let activityController = UIActivityViewController(activityItems: [imageView.image!], applicationActivities: nil)
        presentViewController(activityController, animated: true, completion: nil)
    }
    
    
    func showSecondaryMenu() {
        view.addSubview(secondaryMenu)
        
        
        
        let bottomConstraint = secondaryMenu.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let leftConstraint = secondaryMenu.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let rightConstraint = secondaryMenu.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        let heightConstraint = secondaryMenu.heightAnchor.constraintEqualToConstant(44)
        
        NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        view.layoutIfNeeded()
        
        secondaryMenu.alpha = 0
        UIView.animateWithDuration(0.4) {
            self.secondaryMenu.alpha = 1.0
        }
    }
    
    
    func hideSecondaryMenu() {
        UIView.animateWithDuration(0.4, animations: {
            self.secondaryMenu.alpha = 0
            }) { completed in
                if (completed) {
                    self.secondaryMenu.removeFromSuperview()
                }
        }
    }
}


