//
//  UIImage+Extension.swift
//  AceQR
//
//  Created by Roman Rakhlin on 25.05.2020.
//  Copyright © 2020 Roman Rakhlin. All rights reserved.
//

import UIKit

extension UIImage {
    
    var isPortrait: Bool { size.height > size.width }
    var isLandscape: Bool { size.width > size.height }
    var breadth: CGFloat { min(size.width, size.height) }
    var breadthSize: CGSize { .init(width: breadth, height: breadth) }
    var breadthRect: CGRect { .init(origin: .zero, size: breadthSize) }
    
    func rounded(with color: UIColor, width: CGFloat) -> UIImage? {
        
        guard let cgImage = cgImage?.cropping(to: .init(origin: .init(
            x: isLandscape ? ((size.width-size.height)/2).rounded(.down) : .zero,
            y: isPortrait ? ((size.height-size.width)/2).rounded(.down) : .zero), size: breadthSize)) else { return nil }
        
        let bleed = breadthRect.insetBy(dx: -width, dy: -width)
        let format = imageRendererFormat
        
        format.opaque = false

        return UIGraphicsImageRenderer(size: bleed.size, format: format).image { context in
            
            UIBezierPath(ovalIn: .init(
                origin: .zero,
                size: bleed.size)).addClip()
            
            var strokeRect = breadthRect.insetBy(dx: -width/2, dy: -width/2)
            strokeRect.origin = .init(x: width/2, y: width/2)
            
            UIImage(cgImage: cgImage, scale: 1,orientation: imageOrientation).draw(in: strokeRect.insetBy(dx: width/2, dy: width/2))
            
            context.cgContext.setStrokeColor(color.cgColor)
            
            let line: UIBezierPath = .init(ovalIn: strokeRect)
            line.lineWidth = width
            line.stroke()
        }
    }
}
