//
//  UILabelColoring.swift
//  Cryptomat
//
//  Created by Luka Ivanić on 27.07.2021..
//

import UIKit
import Foundation

extension UILabel {
    
    
    
    func updateColor(){
        
        guard var numberText = text else { return }
        
        if numberText.contains("%") {
            numberText.removeLast()
        }
        
        let doubleValue = Double(numberText)
        guard let safeDouble = doubleValue else { return }
        
        if safeDouble > 0 {
            textColor = .systemGreen
        } else if safeDouble < 0 {
            textColor = .systemRed
        }
        
        
        
    }
    
}
