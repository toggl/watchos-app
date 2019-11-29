//
//  DateFormatterExtension.swift
//  TogglWatch
//
//  Created by Juxhin Bakalli on 27/11/19.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation

extension DateFormatter
{
    static let encoderDateFormatter: DateFormatter =
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
