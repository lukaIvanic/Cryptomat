//
//  ViewClickListener.swift
//  Cryptomat
//
//  Created by Luka Ivanić on 07.08.2021..
//

import UIKit
import Foundation

extension UIView {
    
    func setOnClickListener(action: @escaping () -> Void){
        let tapRecogniser = ClickListener(target: self, action: #selector(onViewClicked(sender:)))
        tapRecogniser.onClick = action
        self.addGestureRecognizer(tapRecogniser)
    }
    
    @objc func onViewClicked(sender: ClickListener) {
        if let onClick = sender.onClick {
            onClick()
        }
    }
    
}

class ClickListener: UITapGestureRecognizer {
    var onClick : (() -> Void)? = nil
}
