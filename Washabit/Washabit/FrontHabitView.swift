//
//  FrontHabitView.swift
//  Washabit
//
//  Created by 강현중 on 11/24/24.
//

import SwiftUI

struct FrontHabitView: View {
    let habit: HabitData

    var body: some View {
        Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 350, height: 350)
                    .overlay {
                        // 날짜가 오늘인 데이터만 표시
                        if let todayDaily = habit.sortedDaily.first(where: { Calendar.current.isDate($0.date, inSameDayAs: Date()) }) {
                            WaterFillView(progress: Binding(
                                get: {
                                    CGFloat(todayDaily.count) / CGFloat(habit.goal)
                                },
                                set: { newValue in
                                    todayDaily.count = Int(newValue * CGFloat(habit.goal))
                                }
                            ))
                            .frame(width: 200, height: 200)
                            .onTapGesture {
                                todayDaily.count += 1
                                saveContext()
                            }
                            .onLongPressGesture {
                                if todayDaily.count > 0 {
                                    todayDaily.count -= 1
                                    saveContext()
                                }
                            }
                            
                            Text(habit.title)
                                .font(.title)
                                .padding()
                                .offset(x: -60, y: -140)
                            
                            Text("\(todayDaily.count) / \(habit.goal)")
                                .font(.body)
                                .padding()
                                .foregroundColor(.blue)
                                .offset(x: -100, y: -100)
                        }
                    }
    }
}

