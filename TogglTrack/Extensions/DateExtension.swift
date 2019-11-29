//
//  DateExtension.swift
//  TogglWatch
//
//  Created by Juxhin Bakalli on 29/11/19.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation

extension Date
{
    func toServerEncodedDateString() -> String
    {
        return DateFormatter.encoderDateFormatter.string(from: self).replacingOccurrences(of: "+0000", with: "+00:00")
    }
}
