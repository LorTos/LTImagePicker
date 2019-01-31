//
//  LTPickerConfig.swift
//  LTImagePicker
//
//  Created by Lorenzo Toscani De Col on 31/01/2019.
//

import Foundation

public struct LTPickerConfig {
    var navigationBackgroundColor: UIColor
    var navigationTintColor: UIColor
    var accentColor: UIColor
    
    public init(navBackgroundColor: UIColor, navTintColor: UIColor, accentColor: UIColor) {
        navigationBackgroundColor = navBackgroundColor
        navigationTintColor = navTintColor
        self.accentColor = accentColor
    }
}
