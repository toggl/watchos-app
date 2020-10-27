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
    public init(hex: String) {
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
    
    public func toUIColor() -> UIColor {

        let components = self.components()
        return UIColor(red: components.r, green: components.g, blue: components.b, alpha: components.a)
    }

    private func components() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {

        let scanner = Scanner(string: self.description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0

        let result = scanner.scanHexInt64(&hexNumber)
        if result {
            r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
            g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
            b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
            a = CGFloat(hexNumber & 0x000000ff) / 255
        }
        return (r, g, b, a)
    }
    
    // App colors
    public static var togglGreen = Color(red: 75/255, green: 200/255, blue: 0)
    public static var togglRed = Color(red: 241/255, green: 18/255, blue: 18/255)
    public static var togglPink = Color(red: 229/255, green: 124/255, blue: 216/255)    
    public static var togglDarkRed = Color(red: 77/255, green: 6/255, blue: 6/255)
    public static var togglBlue = Color(red: 6/255, green: 170/255, blue: 245/255)
    public static var togglGray = Color(red: 174/255, green: 180/255, blue: 191/255)
    public static var togglDarkGray = Color(red: 34/255, green: 34/255, blue: 35/255)
}
