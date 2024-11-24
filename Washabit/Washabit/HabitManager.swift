//
//  HabitManager.swift
//  Washabit
//
//  Created by 강현중 on 11/24/24.
//
import SwiftData
import SwiftUI

class HabitManager {
    static func addNewHabit(
        _ title: String,
        _ goal: Int,
        _ startDate: Date,
        _ endDate: Date,
        to modelContext: ModelContext
    ) {
        let newHabit = HabitData(title: title, goal: goal, startDate: startDate, endDate: endDate, daily: [])
        modelContext.insert(newHabit)

        let daysDiff = daysDifference(date1: startDate, date2: endDate)
        let calendar = Calendar.current
        var currentDate = startDate

        for _ in 0...daysDiff {
            let dailyItem = Daily(value: 0, image: "exampleimage", diary: "Diary Entry", date: currentDate)
            newHabit.daily.append(dailyItem)
            modelContext.insert(dailyItem)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        saveContext(modelContext)
    }

    static func deleteHabit(_ habit: HabitData, to modelContext: ModelContext) {
        modelContext.delete(habit)
        saveContext(modelContext)
    }

    static func saveContext(_ modelContext: ModelContext) {
        do {
            try modelContext.save()
        } catch {
            print("저장 실패: \(error)")
        }
    }
}
