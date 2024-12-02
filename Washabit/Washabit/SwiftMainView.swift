import SwiftUI
import SwiftData



struct SwiftMainView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var habits: [HabitData]

    var body: some View {
        ZStack {
            VStack {
                // 삭제 버튼 (위쪽)
                HStack {
                    Spacer()
                    Button(action: {
                        if !habits.isEmpty {
                            HabitManager.deleteHabit(habits[0], to: modelContext)
                        } else {
                            print("삭제할 목표가 없습니다.")
                        }
                    }) {
                        Label("목표 삭제", systemImage: "trash")
                            .font(.headline)
                            .padding(10)
                            .background(Color.red.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)
                    .padding(.trailing, 20)
                }

                Spacer()

                // 탭 뷰 (중앙)
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
                                        withAnimation {
                                            habit.isFlipped.toggle()
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .onAppear {
                        // 현재 선택된 페이지의 색상을 파란색으로 설정
                        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.blue)
                        // 나머지 페이지 점들의 색상을 회색으로 설정
                        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.gray.opacity(0.5))
                    }
                    .frame(width: 350, height: 420)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))

                }

                Spacer()

                // 추가 버튼 (아래쪽)
                HStack {
                    Spacer()
                    Button(action: {
                        let startDate = Date().addingTimeInterval(-7 * 24 * 60 * 60)
                        let endDate = Date().addingTimeInterval(3 * 24 * 60 * 60)
                        HabitManager.addNewHabit(
                            "New Habit",
                            5,
                            startDate,
                            endDate,
                            to: modelContext
                        )
                    }) {
                        Label("새 목표 추가", systemImage: "plus")
                            .font(.headline)
                            .padding(10)
                            .background(Color.blue.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 20)
                    .padding(.trailing, 20)
                }
            }.background(Color("MainColor"))
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
        GeometryReader { geometry in
            let cardWidth = geometry.size.width * 0.9
                    let cardHeight = geometry.size.height * 0.85 // 추가
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                            .frame(width: cardWidth, height: cardHeight) // 동일 크기 설정

                if let todayDaily = habit.sortedDaily.first(where: {
                    Calendar.current.isDate($0.date, inSameDayAs: Date())
                }) {
                    VStack {
                        WaterFillView(progress: Binding(
                            get: {
                                CGFloat(todayDaily.count) / CGFloat(habit.goal)
                            },
                            set: { newValue in
                                todayDaily.count = Int(newValue * CGFloat(habit.goal))
                            }
                        ))
                        .frame(width: cardWidth * 0.6)

                        VStack(spacing: 10) {
                            Text(habit.title)
                                .font(.system(size: cardWidth * 0.06, weight: .bold))
                                .padding(.top)
                            
                            Text("\(todayDaily.count) / \(habit.goal)")
                                .font(.system(size: cardWidth * 0.05))
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
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
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    func backHabitView(habit: HabitData) -> some View {
        GeometryReader { geometry in
            let cardWidth = geometry.size.width * 0.9
                    let cardHeight = geometry.size.height * 0.85 // 추가
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                            .frame(width: cardWidth, height: cardHeight)

                VStack(spacing: 20) {
                    Text("\(habit.startDate.toString()) ~ \(habit.endDate.toString())")
                        .font(.system(size: cardWidth * 0.04))
                        .foregroundColor(.gray)
                        .frame(width: cardWidth, height: 10, alignment: .topLeading)
                    
                    HStack {
                        VStack {
                            Text(habit.title)
                                .font(.system(size: cardWidth * 0.06, weight: .bold))
                                .padding(.top, 10)

                            let consecutiveDays = habit.consecutiveAchievedDays()
                            
                            VStack(spacing: 8) {
                                let totalDays = max(1, daysDifference(date1: habit.startDate, date2: habit.endDate.addingTimeInterval(24 * 60 * 60)))
                                let elapsedDays = max(0, daysDifference(date1: habit.startDate, date2: min(Date(), habit.endDate).addingTimeInterval(24 * 60 * 60)))
                                let percentage = String(format: "%.1f", Double(elapsedDays) / Double(totalDays) * 100)
                                
                                Text("진행률: \(percentage)%")
                                    .font(.system(size: cardWidth * 0.05))
                                    .foregroundColor(.blue)

                                ProgressView(value: Double(elapsedDays), total: Double(totalDays))
                                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                    .frame(width: cardWidth * 0.6)
                            }
                            
                            if consecutiveDays == 0 {
                                Text("오늘의 목표를 달성해 보세요!")
                                    .font(.system(size: cardWidth * 0.05, weight: .bold))
                                    .foregroundColor(.orange)
                            } else {
                                Text("🔥 \(consecutiveDays)일 연속 달성 중!")
                                    .font(.system(size: cardWidth * 0.05, weight: .bold))
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        if let firstDaily = habit.sortedDaily.first {
                            Image(firstDaily.image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: cardWidth * 0.3, height: cardWidth * 0.3)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.blue, lineWidth: 2)
                                )
                        }
                    }
                    ZStack {
                        let dynamicHeight = selectedDate == nil ? geometry.size.height * 0.3 : geometry.size.height * 0.5

                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color("MediumBlue"))
                            .frame(width: geometry.size.width * 0.85, height: dynamicHeight)
                            .animation(.easeInOut(duration: 0.3), value: selectedDate)

 
                        VStack(spacing: 20) {

                            Text("최근 2주간의 기록")
                                .frame(width: cardWidth * 0.9, alignment: .topLeading)
                                .foregroundColor(.white)
                                .padding(.top, selectedDate == nil ? 10 : 20)
                                .animation(.easeInOut(duration: 0.3), value: selectedDate)

                            // 조절 패널
                            if let selectedDate = selectedDate,
                               let daily = habit.sortedDaily.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
                                VStack(spacing: 10) {
                                    HStack(spacing: 20) {
                                        Button(action: {
                                            if daily.count > 0 {
                                                daily.count -= 1
                                                HabitManager.saveContext(modelContext)
                                            }
                                        }) {
                                            Text("-")
                                                .font(.title)
                                                .frame(width: 40, height: 40)
                                                .background(Color.clear)
                                                .foregroundColor(.white)
                                                .clipShape(Circle())
                                        }

                                        Text("\(daily.count)")
                                            .font(.title)
                                            .foregroundColor(.white)

                                        Button(action: {
                                            daily.count += 1
                                            HabitManager.saveContext(modelContext)
                                        }) {
                                            Text("+")
                                                .font(.title)
                                                .frame(width: 40, height: 40)
                                                .background(Color.clear)
                                                .foregroundColor(.white)
                                                .clipShape(Circle())
                                        }
                                    }
                                    .padding(.bottom, 10)
                                }
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.black.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                                                .foregroundColor(.white)
                                        )
                                )
                                .shadow(radius: 5)
                                .padding(.horizontal, 10)
                                .transition(.move(edge: .top))
                                .animation(.easeInOut(duration: 0.3), value: selectedDate)
                            }

                            // LazyVGrid (2주 데이터)
                            LazyVGrid(
                                columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 7),
                                spacing: 10
                            ) {
                                ForEach(recentTwoWeeksDates(), id: \.self) { date in
                                    let daily = habit.sortedDaily.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
                                    let isCompleted = daily?.count ?? 0 >= habit.goal

                                    Button(action: {
                                        if date >= habit.startDate {
                                            selectedDate = (selectedDate == date) ? nil : date
                                        }
                                    }) {
                                        Circle()
                                            .fill(date < habit.startDate ? Color.gray.opacity(0.4) : (isCompleted ? Color.teal : Color("StrongBlue-comp")))
                                            .frame(width: cardWidth * 0.1, height: cardWidth * 0.1)
                                            .overlay(
                                                Text(formattedDate(date: date))
                                                    .font(.system(size: cardWidth * 0.035))
                                                    .foregroundColor(.white)
                                            )
                                            .opacity(date < habit.startDate ? 0.5 : 1.0)
                                    }
                                    .disabled(date < habit.startDate)
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.top, selectedDate == nil ? 0 : -20)
                            .transition(.move(edge: .bottom))
                            .animation(.easeInOut(duration: 0.3), value: selectedDate)
                        }
                        .padding(10)
                        .frame(width: geometry.size.width * 0.85, height: dynamicHeight)
                    }




                       
                    // 팝업
                    /*
                        if let selectedDate = selectedDate,
                           let daily = habit.sortedDaily.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
                            CountAdjustPopoverView(
                                habit: habit,
                                daily: daily,
                                onClose: {
                                    withAnimation { self.selectedDate = nil }
                                }
                            )
                            .frame(width: cardWidth * 0.85)
                            .offset(y: -geometry.size.height*0.08) // 팝업 위치를 버튼 배열 바로 위로 설정
                            .transition(.scale)
                            .zIndex(1)
                        }
                     */
                    }
                }
                .padding(20)
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

