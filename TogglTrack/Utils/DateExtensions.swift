//
//  DateExtensions.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 22/11/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation

private let shortTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter
}()

private let simpleDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "E, d MMM"
    return formatter
}()

private let encoderDateFormatter: DateFormatter =
{
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
}()

extension Date
{
    public func ignoreTimeComponents() -> Date
    {
        let units : NSCalendar.Unit = [ .year, .month, .day];
        let calendar = Calendar.current;
        return calendar.date(from: (calendar as NSCalendar).components(units, from: self))!
    }
    
    public func toDayString() -> String
    {
        if Calendar.current.isDateInToday(self) {
            return "Today"
        }
        
        if Calendar.current.isDateInYesterday(self) {
            return "Yesterday"
        }
        
        return simpleDateFormatter.string(from: self)
    }
    
    public func toTimeString() -> String
    {
        return shortTimeFormatter.string(from: self)
    }
    
    public func toServerEncodedDateString() -> String
    {
        return encoderDateFormatter.string(from: self).replacingOccurrences(of: "+0000", with: "+00:00")
    }
}
