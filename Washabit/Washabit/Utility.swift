//
//  Utility.swift
//  Washabit
//
//  Created by 강현중 on 11/24/24.
//

import Foundation

func recentTwoWeeksDates() -> [Date] {
    let calendar = Calendar.current
    let today = Date()
    return (0..<14).compactMap { calendar.date(byAdding: .day, value: -$0, to: today) }.reversed()
}

func formattedDate(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd"
    return formatter.string(from: date)
}

func daysDifference(date1: Date, date2: Date) -> Int {
    let calendar = Calendar.current
    let startOfDate1 = calendar.startOfDay(for: date1)
    let startOfDate2 = calendar.startOfDay(for: date2)
    let components = calendar.dateComponents([.day], from: startOfDate1, to: startOfDate2)
    return components.day ?? 0
}

extension Date {
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: self)
    }
}

