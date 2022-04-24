//
//  File.swift
//  
//
//  Created by Shunzhe on 2022/04/24.
//

import Foundation
import UserNotifications

@available(macOS 10.14, *)
@available(iOS 10.0, *)
extension UNNotificationRequest {
    func schedule() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(self) { (error) in
            if error != nil {
                // Handle any errors.
            }
        }
    }
}
