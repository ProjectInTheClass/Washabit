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
    var goal: Int
    var startDate: Date
    var endDate: Date
    var isFlipped: Bool
    @Relationship(deleteRule: .cascade) var daily: [Daily]

    init(title: String, goal: Int, startDate: Date, endDate: Date, isFlipped: Bool = false, daily: [Daily]) {
        self.id = UUID()
        self.title = title
        self.goal = goal
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
    var image: String
    var diary: String
    var date: Date

    init(value: Int, image: String, diary: String, date: Date) {
        self.count = value
        self.image = image
        self.diary = diary
        self.date = date
    }
}

extension HabitData {
    /// 오늘을 기준으로 몇 일 연속 목표를 달성했는지 계산
    func consecutiveAchievedDays() -> Int {
        let today = Date()
        var consecutiveDays = 0
        
        // 정렬된 Daily 데이터를 역순으로 순회
        for daily in sortedDaily.reversed() {
            if Calendar.current.isDateInToday(daily.date) || Calendar.current.isDate(daily.date, inSameDayAs: today.addingTimeInterval(-Double(consecutiveDays) * 24 * 60 * 60)) {
                // 목표 달성 여부 확인
                if daily.count >= goal {
                    consecutiveDays += 1
                } else {
                    break // 연속 달성이 끊기면 종료
                }
            }
        }
        
        return consecutiveDays
    }
}




