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
        _ type : String,
        _ goalCount: Int,
        _ goalPercentage: Int,
        _ startDate: Date,
        _ endDate: Date,
        to modelContext: ModelContext
    ) {
        let newHabit = HabitData(title: title, type: type, goalCount: goalCount, goalPercentage: goalPercentage, startDate: startDate, endDate: endDate, daily: [])
        modelContext.insert(newHabit)
//
//        let daysDiff = daysDifference(date1: startDate, date2: endDate)
//        let calendar = Calendar.current
//        var currentDate = startDate
//
//        for _ in 0...daysDiff {
//            let dailyItem = Daily(value: 0, image: "exampleimage", diary: "Diary Entry", date: Date())
//            newHabit.daily.append(dailyItem)
//            modelContext.insert(dailyItem)
//            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
//        }
        
        let dailyItem = Daily(value: 0, image: nil, diary: "", date: startDate)
       newHabit.daily.append(dailyItem)
       modelContext.insert(dailyItem)
       saveContext(modelContext)
    }
    
    static func addNewDaily(
        _ habitId: UUID,
        _ value: Int,
        _ image: Data,
        _ diary: String,
        _ date: Date,
        to modelContext:ModelContext
    ){
        guard let habit = try? modelContext.fetch(FetchDescriptor<HabitData>(predicate: #Predicate { $0.id == habitId })).first else {
            print("해당하는 습관을 찾을 수 없습니다.")
            return
        }
        
        let dailyItem = Daily(value:value, image:image, diary:diary, date:date)
        habit.daily.append(dailyItem)
        modelContext.insert(dailyItem)
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
