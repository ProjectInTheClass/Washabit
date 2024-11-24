import SwiftUI
import SwiftData


// 메인 뷰
struct SwiftMainView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var habits: [HabitData]

    var body: some View {
        Button("새 목표 추가") {
            let startDate = Date().addingTimeInterval(-3 * 24 * 60 * 60)
                    let endDate = Date().addingTimeInterval(3 * 24 * 60 * 60)
            HabitManager.addNewHabit(
                          "New Habit",
                          5,
                          startDate,
                          endDate,
                          to: modelContext
                      )
                }
                .offset(x: 0, y: -100)
                
                Button("목표 삭제") {
                    HabitManager.deleteHabit(habits[0], to: modelContext)
                }
                .offset(x: 0, y: -150)
        if habits.isEmpty {
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .frame(width: 350, height: 350)
                .overlay {
                    Text("아직 목표가 없습니다. 추가하세요!")
                }
        } else {
            TabView {
                ForEach(habits) { habit in
                    // endDate가 오늘을 기준으로 지난 목표는 표시하지 않음
                    if habit.endDate >= Date() {
                        ZStack {
                            if !habit.isFlipped {
                                frontHabitView(habit: habit)
                            } else {
                                backHabitView(habit: habit)
                            }
                        }
                        .rotation3DEffect(
                            .degrees(habit.isFlipped ? 180 : 0),
                            axis: (x: 0, y: 1, z: 0),
                            perspective: 0.5
                        )
                        .onTapGesture {
                            if selectedDate != nil {
                                selectedDate = nil
                            } else {
                                // 팝업이 닫혀 있으면 상태를 변경
                                withAnimation {
                                    habit.isFlipped.toggle()
                                }
                            }
                        }
                    }
                }
            }
            .frame(width: 350, height: 420)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        }
    }

    @State private var selectedDate: Date? = nil // 선택된 날짜
    

    private func printAllHabits() {
        do {
            let allHabits = try modelContext.fetch(FetchDescriptor<HabitData>())
            for habit in allHabits {
                // 항상 정렬된 daily 배열을 사용
                print("Habit: \(habit.title), Daily: \(habit.sortedDaily.map { $0.date.toString() })")
            }
        } catch {
            print("데이터 가져오기 실패: \(error)")
        }
    }


    func frontHabitView(habit: HabitData) -> some View {
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
                        HabitManager.saveContext(modelContext)
                    }
                    .onLongPressGesture {
                        if todayDaily.count > 0 {
                            todayDaily.count -= 1
                            HabitManager.saveContext(modelContext)
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




    func backHabitView(habit: HabitData) -> some View {
        ZStack {
            // 뒷면 전체 배경
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .frame(width: 350, height: 350)
                .onTapGesture {
                    if selectedDate != nil {
                        // 팝업이 열려 있으면 닫기
                        withAnimation {
                            selectedDate = nil
                        }
                    } else {
                        // 팝업이 닫혀 있으면 앞면으로 전환
                        withAnimation {
                            habit.isFlipped = false
                        }
                    }
                }
            
            VStack(spacing: 16) {
                // 진행 퍼센트 계산
                let totalDays = max(1, daysDifference(date1: habit.startDate, date2: habit.endDate + 1))
                let elapsedDays = max(0, daysDifference(date1: habit.startDate, date2: Date()) + 1)
                let percentage = String(format: "%.1f", Double(elapsedDays) / Double(totalDays) * 100)
                
                Text("\(percentage)%")
                    .font(.title)
                    .bold()
                
                ProgressView(value: Double(elapsedDays), total: Double(totalDays))
                    .progressViewStyle(LinearProgressViewStyle(tint: .red))
                    .frame(width: 240)
                
                Text("\(habit.startDate.toString()) ~ \(habit.endDate.toString())")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                // 최근 2주 날짜 그리드
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                    ForEach(recentTwoWeeksDates(), id: \.self) { date in
                        let isBeforeStart = date < habit.startDate
                        
                        ZStack {
                            Button {
                                if !isBeforeStart {
                                    selectedDate = (selectedDate == date) ? nil : date
                                }
                            } label: {
                                Text(formattedDate(date: date))
                                    .frame(width: 40, height: 40)
                                    .background(isBeforeStart ? Color.gray.opacity(0.4) : Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    .opacity(isBeforeStart ? 0.5 : 1.0)
                            }
                            .disabled(isBeforeStart)
                        }
                    }
                }
                .frame(width: 300, height: 200) // 고정된 크기
            }
            .padding()
            .frame(maxHeight: .infinity)

            // 팝업을 LazyVGrid 밖으로 이동
            if let selectedDate = selectedDate {
                if let daily = habit.sortedDaily.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
                    CountAdjustPopoverView(
                        habit: habit,
                        daily: daily,
                        onClose: {
                            withAnimation {
                                self.selectedDate = nil
                            }
                        }
                    )
                    .offset(y: -60)
                    .transition(.scale)
                    .zIndex(1) // 팝업을 그리드 위에 띄우기
                }
            }

            // 이미지
            if let firstDaily = habit.sortedDaily.first {
                Image(firstDaily.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .offset(x: 100, y: -100)
            }
        }
        .rotation3DEffect(
            .degrees(habit.isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
    }




    struct CountAdjustPopoverView: View {
        var habit: HabitData
        var daily: Daily
        var onClose: () -> Void
        @Environment(\.modelContext) private var modelContext

        var body: some View {
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    Button(action: {
                        if daily.count > 0 {
                            daily.count -= 1
                            HabitManager.saveContext(modelContext)
                        }
                    }) {
                        Text("-")
                            .font(.title3)
                            .frame(width: 30, height: 30)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    Text("\(daily.count)")
                        .font(.caption)
                    Button(action: {
                        daily.count += 1
                        HabitManager.saveContext(modelContext)
                    }) {
                        Text("+")
                            .font(.title3)
                            .frame(width: 30, height: 30)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                }
            }
            .padding(8)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(radius: 4)
            .frame(width: 120)
        }
    }




    struct WaterFillView: View {
        @Binding var progress: CGFloat
        @State private var waveOffset: CGFloat = 0.0
        @State private var timer: Timer?

        var body: some View {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 213, height: 213)
        
                WaterShape(level: progress, waveOffset: waveOffset)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.lightBlue.opacity(0.1), Color.lightBlue]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
                    .animation(.easeInOut(duration: 0.8), value: progress)
                
                Circle()
                    .strokeBorder(Color.blue.opacity(0.3), lineWidth: 10)
                    .background(Circle().fill(Color.clear))
                    .frame(width: 215, height: 215)
            }
            .onAppear {
                startWaveAnimation()
            }
            .onDisappear {
                stopWaveAnimation()
            }
        }
        
        private func startWaveAnimation() {
            stopWaveAnimation()
            timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
                waveOffset += 0.07
            }
        }
        
        private func stopWaveAnimation() {
            timer?.invalidate()
            timer = nil
        }
    }

    struct WaterShape: Shape {
        var level: CGFloat
        var waveOffset: CGFloat

        var animatableData: AnimatablePair<CGFloat, CGFloat> {
            get { AnimatablePair(level, waveOffset) }
            set {
                level = newValue.first
                waveOffset = newValue.second
            }
        }
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let waterHeight = rect.height * (1.0 - level)
            
            path.move(to: CGPoint(x: 0, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: waterHeight))
            
            for x in stride(from: 0.0, to: Double(rect.width), by: 1.0) {
                let relativeX = CGFloat(x) / rect.width
                let yOffset = sin(relativeX * .pi * 2 + waveOffset) * 10
                path.addLine(to: CGPoint(x: CGFloat(x), y: waterHeight + yOffset))
            }
            
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.closeSubpath()
            
            return path
        }
    }
}
// 프리뷰

#Preview {
    SwiftMainView()
        .modelContainer(for: [HabitData.self, Daily.self])
}

