//
//  Date+Extension.swift
//  WeeklyPlan
//
//  Created by Shunzhe Ma on 2021/12/04.
//

import Foundation

extension Date {
    
    func getAllDaysOfCurrentWeek() -> [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: self)
        let dayOfWeek = calendar.component(.weekday, from: today)
        let weekdays = calendar.range(of: .weekday, in: .weekOfYear, for: today)!
        let days = (weekdays.lowerBound ..< weekdays.upperBound)
            .compactMap { calendar.date(byAdding: .day, value: $0 - dayOfWeek, to: today) }
//            .filter { !calendar.isDateInWeekend($0) }
        return days
    }
    
    func getHourMinuteSecondRemovedDate() -> Date? {
        return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)
    }
    
    func getPreviousDay() -> Date? {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)
    }
    
    func getNextDay() -> Date? {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)
    }
    
    func getFormattedString(dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .medium) -> String {
        return DateFormatter.localizedString(from: self, dateStyle: dateStyle, timeStyle: timeStyle)
    }
    
    func isSameDay(comparingTo: Date) -> Bool {
        let originalDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: self)
        let comparingDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: comparingTo)
        let sameYear = originalDateComponents.year == comparingDateComponents.year
        let sameMonth = originalDateComponents.month == comparingDateComponents.month
        let sameDay = originalDateComponents.day == comparingDateComponents.day
        return sameYear && sameMonth && sameDay
    }
    
    /*
     This function returns strings based on the week
     - whether it's current week
     - (x) weeks ago
     - (x) weeks later
     */
    enum relativeWeek {
        case pastWeeks(weeksAgo: Int)
        case currentWeek
        case futureWeeks(weeksLater: Int)
        case differentYear
    }
    
    func isSameWeekAs(date: Date) -> Bool {
        let self_components = Calendar.current.dateComponents([.year, .weekOfYear], from: self)
        let date_components = Calendar.current.dateComponents([.year, .weekOfYear], from: date)
        guard let self_yearNumber = self_components.year,
              let self_weekNumber = self_components.weekOfYear,
              let date_yearNumber = date_components.year,
              let date_weekNumber = date_components.weekOfYear else {
                  return false
              }
        return (self_yearNumber == date_yearNumber) && (self_weekNumber == date_weekNumber)
    }
    
    /*
     Get an Int based on the year, month, day
     */
    func getYearMonthDayIntValue() -> Int {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        guard let year = components.year,
              let month = components.month,
              let day = components.day else {
                  return self.hashValue
              }
        let intStr = "\(year)\(month)\(day)"
        guard let intVal = Int(intStr) else {
            return self.hashValue
        }
        return intVal
    }
    
    /*
     Check if the user has specified a time at all
     */
    func isHourMinuteEmpty() -> Bool {
        let components = Calendar.current.dateComponents([.hour, .minute], from: self)
        guard let hour = components.hour,
              let minute = components.minute else {
                  return false
              }
        return (hour == 0) && (minute == 0)
    }
    
    func getDaysInWeekString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayInWeek = dateFormatter.string(from: self)
        return dayInWeek
    }
    
    func getDayNumberInt() -> Int? {
        let components = Calendar.current.dateComponents([.day], from: self)
        guard let dayNumber = components.day else {
            return nil
        }
        return dayNumber
    }
    
    func getHourNumberInt() -> Int? {
        let components = Calendar.current.dateComponents([.hour], from: self)
        guard let hourNumber = components.hour else {
            return nil
        }
        return hourNumber
    }
    
    func getWeekDayName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayInWeek = dateFormatter.string(from: self)
        return dayInWeek
    }
    
}
