//
//  HabitData.swift
//  Washabit
//
//  Created by 강현중 on 11/24/24.
//

import SwiftData
import SwiftUI
import Foundation

/// HabitData 모델: 사용자가 설정한 목표를 관리
@Model
class HabitData: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var type: String
    var goalCount: Int
    var goalPercentage: Int
    var startDate: Date
    var endDate: Date
    var isFlipped: Bool
    @Relationship(deleteRule: .cascade) var daily: [Daily]

    init(title: String, type: String, goalCount: Int, goalPercentage: Int, startDate: Date, endDate: Date, isFlipped: Bool = false, daily: [Daily]) {
        self.id = UUID()
        self.title = title
        self.type = type
        self.goalCount = goalCount
        self.goalPercentage = goalPercentage
        self.startDate = startDate
        self.endDate = endDate
        self.isFlipped = isFlipped
        self.daily = daily
    }
    
    /// 항상 정렬된 daily 배열 반환
    var sortedDaily: [Daily] {
        daily.sorted { $0.date < $1.date }
    }
}

/// Daily 모델: 매일의 진행 상황 및 기록 관리
@Model
class Daily: Identifiable {
    var count: Int
    @Relationship(deleteRule: .cascade) var diary: [Diary]?
    var date: Date

    init(value: Int, diary: [Diary]?, date: Date) {
        self.count = value
        self.diary = diary
        self.date = date
    }
    
    var sortedDiary: [Diary] {
        if let diary = diary {
            return diary.sorted { $0.date > $1.date }
        }
        else{
            return []
        }
    }
}

@Model
class Diary: Identifiable {
    @Attribute(.unique) var id: UUID
    var count: Int
    var content: String
    var image: Data?
    var date: Date
    
    init(count: Int, content: String, image:Data?, date:Date){
        self.id = UUID()
        self.count = count
        self.content = content
        self.image = image
        self.date = date
    }
}

extension HabitData {
    /// 오늘을 기준으로 몇 일 연속 목표를 달성했는지 계산
    func consecutiveAchievedDays() -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        var consecutiveDays = 0
        
        // 정렬된 Daily 데이터를 역순으로 순회
        for daily in sortedDaily.reversed() {
            let dailyDate = Calendar.current.startOfDay(for: daily.date)
            if dailyDate > today {
                continue
            }
            if Calendar.current.isDateInToday(dailyDate) || Calendar.current.isDate(dailyDate, inSameDayAs: today.addingTimeInterval(-Double(consecutiveDays) * 24 * 60 * 60)) {
                // 목표 달성 여부 확인
                if (type == "고치고 싶은" && daily.count <= goalCount) || (type == "만들고 싶은" && daily.count >= goalCount) {
                    consecutiveDays += 1
                } else {
                    break // 연속 달성이 끊기면 종료
                }
            }
            
        }
        
        return consecutiveDays
    }
    
    func finishedHabits(from habits: [HabitData]) -> [HabitData] {
        let today = Calendar.current.startOfDay(for: Date())
        
        // endDate가 오늘보다 이전인 habit 필터링
        let filteredHabits = habits.filter { habit in
            habit.endDate < today
        }
        
        return filteredHabits
//        return habits
    }
    
    func habitInformations(habit: HabitData) -> (maxCount: Int, minCount: Int) {
        var maxCount = Int.min
        var minCount = Int.max
        
        // 최고 기록과 최저 기록 계산
        for daily in habit.daily {
            maxCount = max(maxCount, daily.count)
            minCount = min(minCount, daily.count)
        }
        
        // 찾은 값이 없을 때 0으로 반환
        if maxCount == Int.min {
            maxCount = 0
        }
        if minCount == Int.max{
            minCount = 0
        }
        
        return (maxCount, minCount)
    }
}


    
    // 더미데이터
//    static let sampleData: [HabitData] = [
//        HabitData(
//            title: "손톱 물어뜯기 그만!",
//            type:"고치고 싶은",
//            goalCount: 5,
//            goalPercentage: 75,
//            startDate: Date().addingTimeInterval(-14 * 24 * 60 * 60),
//            endDate: Date().addingTimeInterval(3 * 24 * 60 * 60),
//            daily: [
//                Daily(value: 3, image: nil, diary: "매일 까먹지 말기", date: Date().addingTimeInterval(-14 * 24 * 60 * 60)),
//                Daily(value:4, image: nil, diary: "까먹고 횟수를 넘겼다ㅠ", date: Date().addingTimeInterval(-13 * 24 * 60 * 60)),
//                Daily(value:5, image:nil, diary:"오늘은 시작한 날!", date:Date().addingTimeInterval(-12 * 24 * 60 * 60)),
//                Daily(value: 7, image: nil, diary: "매일 까먹지 말기", date: Date().addingTimeInterval(-11 * 24 * 60 * 60)),
//                Daily(value:8, image: nil, diary: "까먹고 횟수를 넘겼다ㅠ", date: Date().addingTimeInterval(-10 * 24 * 60 * 60)),
//                Daily(value:3, image:nil, diary:"오늘은 시작한 날!", date:Date().addingTimeInterval(-9 * 24 * 60 * 60)),
//                Daily(value: 2, image: nil, diary: "매일 까먹지 말기", date: Date().addingTimeInterval(-8 * 24 * 60 * 60)),
//                Daily(value:7, image: nil, diary: "까먹고 횟수를 넘겼다ㅠ", date: Date().addingTimeInterval(-7 * 24 * 60 * 60)),
//                Daily(value:3, image:nil, diary:"오늘은 시작한 날!", date:Date().addingTimeInterval(-6 * 24 * 60 * 60)),
//                Daily(value: 7, image: nil, diary: "매일 까먹지 말기", date: Date().addingTimeInterval(-5 * 24 * 60 * 60)),
//                Daily(value:1, image: nil, diary: "까먹고 횟수를 넘겼다ㅠ", date: Date().addingTimeInterval(-4 * 24 * 60 * 60)),
//                Daily(value:4, image:nil, diary:"오늘은 시작한 날!", date:Date().addingTimeInterval(-3 * 24 * 60 * 60)),
//                Daily(value: 5, image: nil, diary: "매일 까먹지 말기", date: Date().addingTimeInterval(-2 * 24 * 60 * 60)),
//                Daily(value:2, image: nil, diary: "까먹고 횟수를 넘겼다ㅠ", date: Date().addingTimeInterval(-1 * 24 * 60 * 60)),
//                Daily(value: 3, image: nil, diary: "다시 시작하는거야!!", date: Date())
//                
//            ]
//        ),
//        HabitData(
//            title: "이불 정리하기",
//            type:"만들고 싶은",
//            goalCount:1,
//            goalPercentage: 80,
//            startDate: Date(),
//            endDate: Date().addingTimeInterval(10 * 24 * 60 * 60),
//            daily: [
//                Daily(value:1, image:nil, diary:"아침에 이불 정리하니까 상쾌하다", date: Date())
//            ]
//        )
//    ]




