//
//  HabitData.swift
//  Washabit
//
//  Created by 강현중 on 11/24/24.
//

import SwiftData
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
