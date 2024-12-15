//
//  WashabitApp.swift
//  Washabit
//
//  Created by 강현중 on 11/5/24.
//

import SwiftUI
import SwiftData

@main
struct WashabitApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [HabitData.self, Daily.self]) // 등록된 모델 추가
        }
    }
}

