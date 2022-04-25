//
//  ScheduledNotificationsHelper.swift
//  Detatan-TOEIC
//
//  Created by Shunzhe on 2022/04/24.
//

#if os(iOS)

import Foundation
import UserNotifications
import UIKit
import SwiftUI

@available(iOS 14, *)
public class ScheduledNotificationsHelper {
    
    static public let shared = ScheduledNotificationsHelper()
    
    static let TestNotificationIdentifier: String = "testnotification"
    
    var userSettings: NotificationSettingsInput?
    var notificationContent: UNMutableNotificationContent?
    
    /*
     You have to call this setup function when your app launches
     You can access and change the `userSettings` and `notificationContent` everytime it changes in your app.
     */
    public func updateConfig(userSettings: NotificationSettingsInput, notificationContent: UNMutableNotificationContent) {
        self.userSettings = userSettings
        self.notificationContent = notificationContent
    }
    
    /**
     Set up the notification for the next day
     - Since only one notification (the one for the next day) is scheduled when this function is called. **You need to call this function at least once a day.** You can just add this function to .onAppear or similar functions in your views.
     - It's okay to call this function multiple times, it will cancel all pending notifications and schedule a new one; there won't be multiple notifications.
     - Call this function whenever your notification content changes
     - If it's a `isTestRequest`, notifications will be sent 5 seconds later to show the user.
     */
    public func cancelAllAndScheduleForTomorrow(isTestRequest: Bool = false) {
        guard let userSettings = userSettings,
              let notificationContent = notificationContent else {
            return
        }
        // Clear already delievered notifications
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        // Only set if user chooses to receive daily notifications
        guard userSettings.isNotificationsTurnedOn else {
            return
        }
        // Handle test requests
        if isTestRequest {
            generateNotificationRequest(forTodoAtDate: Date(), isTestRequest: true).schedule()
            return
        }
        UNUserNotificationCenter.current().getPendingNotificationRequests { allRequests in
            // Filter out test requests
            // test requests do not need to be processed
            let requests = allRequests.filter { request in
                return request.identifier != ScheduledNotificationsHelper.TestNotificationIdentifier
            }
            // Calculate the dates
            let startOfToday = Calendar.current.startOfDay(for: Date())
            guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: startOfToday),
                  let todayAtScheduledTime = Calendar.current.date(byAdding: .hour, value: userSettings.delieveryTimeHourNumber, to: startOfToday),
                  let tomorrowAtScheduledTime = Calendar.current.date(byAdding: .hour, value: userSettings.delieveryTimeHourNumber, to: tomorrow) else {
                return
            }
            let firstScheduledNotificationTime = (requests.first?.trigger as? UNCalendarNotificationTrigger)?.nextTriggerDate()
            /*
             Three cases:
             */
            var request: UNNotificationRequest?
            if requests.isEmpty {
                // 1. No notifications scheduled at all, schedule a notification for tomorrow
                request = self.generateNotificationRequest(forTodoAtDate: tomorrowAtScheduledTime)
            } else if firstScheduledNotificationTime?.isSameDay(comparingTo: tomorrow) ?? false {
                // 2. Notification scheduled for tomorrow, cancel all notifications, and re-schedule a notification for tomorrow
                self.cancelAllNotifications()
                request = self.generateNotificationRequest(forTodoAtDate: tomorrowAtScheduledTime)
            } else if (firstScheduledNotificationTime?.isSameDay(comparingTo: Date()) ?? false),
                      (firstScheduledNotificationTime ?? Date()) > Date() {
                // 3. Notification scheduled for today (for example, opened the app at 1:00 am while scheduled notification is at 9:00 am), cancel all notifications, and re-schedule a notification for today
                self.cancelAllNotifications()
                request = self.generateNotificationRequest(forTodoAtDate: todayAtScheduledTime)
            } else {
                // Strange... Let's cancel all notifications and wait for next time's notification set up
                self.cancelAllNotifications()
            }
            // Schedule the notification
            guard let request = request else {
                return
            }
            request.schedule()
        }
    }
    
    private func generateNotificationRequest(forTodoAtDate: Date, isTestRequest: Bool = false) -> UNNotificationRequest {
        var trigger: UNNotificationTrigger
        if isTestRequest {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        } else {
            trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: forTodoAtDate), repeats: false)
        }
        // Schedule the notification
        var requestID = UUID().uuidString
        /// if it's a test request, set the UUID to test
        if isTestRequest {
            requestID = ScheduledNotificationsHelper.TestNotificationIdentifier
        }
        let request = UNNotificationRequest(identifier: requestID,
                                            content: self.notificationContent,
                                            trigger: trigger)
        return request
    }
    
    public func onNotificationInitialSetup(result: @escaping (Bool) -> Void) {
        cancelAllNotifications()
        // Request permission
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if error == nil,
               granted {
                // Schedule first notification
                self.notificationSetUp()
                result(true)
            } else {
                // Handle the error here.
                result(false)
            }
        }
    }
    
    public func onNotificationTurnedOff() {
        cancelAllNotifications()
    }
    
    private func cancelAllNotifications() {
        let center = UNUserNotificationCenter.current()
        // to remove all delivered notifications
        center.removeAllDeliveredNotifications()
        // Remove all pending notifications that are not test ones
        center.getPendingNotificationRequests { requests in
            requests.forEach { request in
                if request.identifier != ScheduledNotificationsHelper.TestNotificationIdentifier {
                    center.removePendingNotificationRequests(withIdentifiers: [request.identifier])
                }
            }
        }
        DispatchQueue.main.async {
            // to clear the icon notification badge
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    
}

#endif
