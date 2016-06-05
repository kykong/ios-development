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
    var intensity: Double { get }
    var intensityMinMax: [Double] { get }
}

public func clamp(minVal: Int, maxVal: Int, value: Int) -> Int {
    return max(min(maxVal, value), minVal)
}

public func clamp(minVal: Double, maxVal: Double, value: Double) -> Double {
    return max(min(maxVal, value), minVal)
}


public class ColourIntensityFilter : FilterType {
    
    public var intensity: Double    // any number >= 0
    var filteredImage: RGBAImage?
    
    let filterColour: Colour
    let DEFAULT_INTENSITY: Double = 4.0
    public var intensityMinMax = [0.0, 5.0]
    
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
                
                var modifier = intensity
                //var modifier = 1 + 4 * (Double(y) / Double(rgbaImage.height))
                //var modifier = 1 + 4 * (1-(Double(y) / Double(rgbaImage.height)))
                if (pixelCol < avgColour) {
                    modifier = 1
                }
                
                let newValue = UInt8(clamp(0, maxVal: 255, value: Int(round(Double(avgColour) + modifier * Double(colourDelta)))))
                switch filterColour {
                    case .Red:    pixel.red   = newValue
                    case .Green:  pixel.green = newValue
                    case .Blue:   pixel.blue  = newValue
                }
                rgbaImage.pixels[index] = pixel
            }
        }
        filteredImage = rgbaImage
        return filteredImage!
    }
    
    public func setIntensity(intensity : Double) {
        reset()
        self.intensity = clamp(1.0, maxVal: intensity, value: intensity)
    }
    
    public func reset() {
        self.intensity = DEFAULT_INTENSITY
        filteredImage = nil
    }
}


public class SepiaFilter : FilterType {
    public var intensity: Double   // from 0 to 1
    public var intensityMinMax = [0.0, 1.0]
    
    var filteredImage: RGBAImage?
    
    let DEFAULT_INTENSITY: Double = 1.0
    
    init() {
        self.intensity = DEFAULT_INTENSITY
    }
    
    public func applyFilter(image: RGBAImage)-> RGBAImage {
        if let img = filteredImage {
            return img
        }
        
        var rgbaImage = image
        for y in 0..<rgbaImage.height {
            for x in 0..<rgbaImage.width {
                let index = y * rgbaImage.width + x
                var pixel = rgbaImage.pixels[index]
                
                
                var outputRed = (intensity * ((Double(pixel.red) * 0.393) + (Double(pixel.green) * 0.769) + (Double(pixel.blue) * 0.189))) + ((1-intensity) * Double(pixel.red))
                outputRed = clamp(0.0, maxVal: 255.0, value: outputRed)
                
                var outputGreen = (intensity * ((Double(pixel.red) * 0.349) + (Double(pixel.green) * 0.686) + (Double(pixel.blue) * 0.168))) + ((1-intensity) * Double(pixel.green))
                outputGreen = clamp(0.0, maxVal: 255.0, value: outputGreen)
                
                var outputBlue = (intensity * ((Double(pixel.red) * 0.272) + (Double(pixel.green) * 0.534) + (Double(pixel.blue) * 0.131))) + ((1-intensity) * Double(pixel.blue))
                outputBlue = clamp(0.0, maxVal: 255.0, value: outputBlue)
                
                
                pixel.red   = UInt8(outputRed)
                pixel.green = UInt8(outputGreen)
                pixel.blue  = UInt8(outputBlue)
                rgbaImage.pixels[index] = pixel
            }
        }
        filteredImage = rgbaImage
        return filteredImage!
    }
    
    public func setIntensity(intensity : Double) {
        reset()
        self.intensity = clamp(0.0, maxVal: 1.0, value: intensity)
    }
    
    public func reset() {
        self.intensity = DEFAULT_INTENSITY
        filteredImage = nil
    }
}


public class ContrastFilter : FilterType {
    public var intensity: Double   // from -255 to 255
    public var intensityMinMax = [-255.0, 255.0]

    var filteredImage: RGBAImage?
    
    let DEFAULT_INTENSITY: Double = 64.0
    
    init() {
        self.intensity = DEFAULT_INTENSITY
    }
    
    public func applyFilter(image: RGBAImage)-> RGBAImage {
        if let img = filteredImage {
            return img
        }
        
        
        let factor = 259.0 * (intensity + 255.0) / (255 * (259 - intensity))
        
        var rgbaImage = image
        for y in 0..<rgbaImage.height {
            for x in 0..<rgbaImage.width {
                let index = y * rgbaImage.width + x
                var pixel = rgbaImage.pixels[index]
                
                let outputRed   = clamp(0, maxVal: 255, value: Int(factor * (Double(pixel.red) - 128) + 128))
                let outputGreen = clamp(0, maxVal: 255, value: Int(factor * (Double(pixel.green) - 128) + 128))
                let outputBlue  = clamp(0, maxVal: 255, value: Int(factor * (Double(pixel.blue) - 128) + 128))
                
                pixel.red   = UInt8(outputRed)
                pixel.green = UInt8(outputGreen)
                pixel.blue  = UInt8(outputBlue)
                rgbaImage.pixels[index] = pixel
            }
        }
        filteredImage = rgbaImage
        return filteredImage!
    }
    
    public func setIntensity(intensity : Double) {
        reset()
        self.intensity = clamp(-255.0, maxVal: 255.0, value: intensity)
    }
    
    public func reset() {
        self.intensity = DEFAULT_INTENSITY
        filteredImage = nil
    }
}



