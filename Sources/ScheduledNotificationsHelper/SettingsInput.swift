//
//  File.swift
//  
//
//  Created by Shunzhe on 2022/04/24.
//

import Foundation

/*
 Settings, provided by the user
 */
public struct NotificationSettingsInput {
    var delieveryTimeHourNumber: Int
    var isNotificationsTurnedOn: Bool
    public init(delieveryTimeHourNumber: Int, isNotificationsTurnedOn: Bool) {
        self.delieveryTimeHourNumber = delieveryTimeHourNumber
        self.isNotificationsTurnedOn = isNotificationsTurnedOn
    }
}
