//
//  ColorExtension.swift
//  TogglWatch WatchKit Extension
//
//  Created by Juxhin Bakalli on 22/11/19.
//  Copyright © 2019 Toggl. All rights reserved.
//

import SwiftUI

extension Color
{
    init(hex: String) {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            fatalError("Color string must be 6 chars long")
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
                
        self.init(
            red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgbValue & 0x0000FF) / 255.0,
            opacity: Double(1.0)
        )
    }
}
