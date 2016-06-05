//
//  Filters.swift
//  Filterer
//
//  Created by Kong Kim Yuan on 5/6/16.
//

import Foundation


public protocol FilterType: class {
    
    func applyFilter(image: RGBAImage)-> RGBAImage
    func setIntensity(intensity: Double)
    func reset()
}



public class ColourIntensityFilter : FilterType {
    
    //var originalImage: RGBAImage?
    var intensity: Double
    var filteredImage: RGBAImage?
    
    let filterColour: Colour
    let DEFAULT_INTENSITY: Double = 4.0
    
    public enum Colour {
        case Red, Green, Blue
    }
    
    
    init(colour: Colour) {
        self.filterColour = colour
        self.intensity = DEFAULT_INTENSITY
    }
    
    
    public func applyFilter(image: RGBAImage)-> RGBAImage {
        if let img = filteredImage {
            return img
        }
        
        
        var rgbaImage = image
        let pixelCount = rgbaImage.width * rgbaImage.height
        
        var colourTotal = 0
        
        for y in 0..<rgbaImage.height {
            for x in 0..<rgbaImage.width {
                
                switch filterColour {
                    case .Red:   colourTotal += (Int)(rgbaImage.pixels[y * rgbaImage.width + x].red)
                    case .Green: colourTotal += (Int)(rgbaImage.pixels[y * rgbaImage.width + x].green)
                    case .Blue:  colourTotal += (Int)(rgbaImage.pixels[y * rgbaImage.width + x].blue)
                }
            }
        }
        let avgColour = colourTotal / pixelCount
        
        for y in 0..<rgbaImage.height {
            for x in 0..<rgbaImage.width {
                let index = y * rgbaImage.width + x
                var pixel = rgbaImage.pixels[index]
                
                var pixelCol = 0
                switch filterColour {
                    case .Red:   pixelCol = Int(pixel.red)
                    case .Green: pixelCol = Int(pixel.green)
                    case .Blue:  pixelCol = Int(pixel.blue)
                }
                
                
                let colourDelta = pixelCol - avgColour
                
                var modifier = 1 + intensity
                //var modifier = 1 + 4 * (Double(y) / Double(rgbaImage.height))
                //var modifier = 1 + 4 * (1-(Double(y) / Double(rgbaImage.height)))
                if (pixelCol < avgColour) {
                    modifier = 1
                }
                
                switch filterColour {
                    case .Red:    pixel.red   = UInt8(max(min(255, Int(round(Double(avgColour) + modifier * Double(colourDelta)))), 0))
                    case .Green:  pixel.green = UInt8(max(min(255, Int(round(Double(avgColour) + modifier * Double(colourDelta)))), 0))
                    case .Blue:   pixel.blue  = UInt8(max(min(255, Int(round(Double(avgColour) + modifier * Double(colourDelta)))), 0))
                }
                rgbaImage.pixels[index] = pixel
            }
        }
        filteredImage = rgbaImage
        return filteredImage!
    }
    
    public func setIntensity(intensity : Double) {
        reset()
        self.intensity = intensity
    }
    
    public func reset() {
        self.intensity = DEFAULT_INTENSITY
        filteredImage = nil
    }
}
