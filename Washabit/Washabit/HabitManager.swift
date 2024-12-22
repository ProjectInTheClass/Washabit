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
        
        let calendar = Calendar.current
        var currentDate = calendar.startOfDay(for: startDate)
        let endOfDay = calendar.startOfDay(for: endDate)
        
        while currentDate <= endOfDay{
            let dailyItem = Daily(value:0, diary:nil, date:currentDate)
            newHabit.daily.append(dailyItem)
            modelContext.insert(dailyItem)
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
       saveContext(modelContext)
    }
    
    static func addNewDiary(
        _ habitId: UUID,
        _ count: Int,
        _ content: String,
        _ image: Data,
        _ date: Date,
        to modelContext:ModelContext
    ){
        guard let habit = try? modelContext.fetch(FetchDescriptor<HabitData>(predicate: #Predicate { $0.id == habitId })).first else {
            print("해당하는 습관을 찾을 수 없습니다.")
            return
        }
        
        let calendar = Calendar.current
        let daily = habit.daily.first {
            calendar.isDate($0.date, equalTo: date, toGranularity: .day)
        }
        
        let diaryItem = Diary(count: count, content: content, image: image, date: date)
        daily?.diary?.append(diaryItem)
        modelContext.insert(diaryItem)
        
        saveContext(modelContext)
    }
    
    static func deleteDiary(_ diary:Diary, to modelContext: ModelContext){
        modelContext.delete(diary)
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
