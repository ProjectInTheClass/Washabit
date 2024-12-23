import SwiftUI
import SwiftData

struct SwiftMainView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    
   @Query private var habits: [HabitData]
    // ------더미데이터로 보기 위해 윗줄 주석처리 & 아랫줄 주석 해제-------
//    var habits :[HabitData] = HabitData.sampleData
    var body: some View {
        NavigationView(content: {
            ZStack {
                VStack {
                    // 삭제 버튼 (위쪽)
//                    HStack {
//                        Spacer()
//                        Button(action: {
//                            if !habits.isEmpty {
//                                HabitManager.deleteHabit(habits[0], to: modelContext)
//                            } else {
//                                print("삭제할 목표가 없습니다.")
//                            }
//                        }) {
//                            Label("목표 삭제", systemImage: "trash")
//                                .font(.headline)
//                                .padding(10)
//                                .background(Color.red.opacity(0.8))
//                                .foregroundColor(.white)
//                                .cornerRadius(10)
//                        }
//                        .padding(.trailing, 20)
//                    }
                    VStack{
                        Spacer()
                        NavigationLink(destination:GalleryView()){
                            HStack{
                                Spacer()
                                ZStack{
                                    Color(.white)
                                    Image("Icons/drawer")
                                }
                                .frame(width:38, height:38)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 2)
                            }
                        }
                        
                        HStack{
                            if !habits.isEmpty{
                                Text("진행중인 목표")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color("StrongBlue-font"))
                                Spacer()
                            }
                        }
                        .padding(.top,20)
                        // 탭 뷰 (중앙)
                        if habits.isEmpty {
                            Spacer()
                            Text("새로운 습관 목표를 추가해주세요!")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color("StrongBlue-font"))
                            Spacer()
                        } else {
                            TabView {
                                ForEach(habits) { habit in
                                    if habit.endDate >= Date(){
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
                                UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color("StrongBlue-font"))
                                // 나머지 페이지 점들의 색상을 회색으로 설정
                                UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.gray.opacity(0.5))
                            }
                            .frame(width: 350, height: 400)
                            .cornerRadius(15)
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                            
                        }
                        
                        Spacer()
                        
                        // 추가 버튼 (아래쪽)
                        HStack {
                            Spacer()
                            /*Button(action: {
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
                             }*/
                            NavigationLink(destination: AddHabitView() ) {
                                Circle()
                                    .fill(Color(.white))
                                    .frame(width:66, height:66)
                                    .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 2)
                                    .overlay(
                                        
                                        HStack {
                                            Image(systemName:"plus")
                                                .font(.system(size: 20))
                                                .foregroundColor(Color("StrongBlue-font"))
                                        }
                                    )
                            }
                        }
                        .padding(.top,70)
                    }
                }
                .padding(30)
                .background(Color("MainColor"))
            }
        })
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
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
            let cardWidth = geometry.size.width * 0.8
            VStack{
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                    //                    .shadow(radius: 5)
                    
                    VStack(spacing:-10) {
                        HStack(alignment: .top){
                            Text(habit.title)
                                .font(.system(size: cardWidth * 0.075))
                                .foregroundColor(Color("StrongBlue-font"))
                            Spacer()
                            HStack(alignment: .top){
                                Circle()
                                    .frame(width:20, height:20)
                                    .foregroundColor(Color("MediumBlue"))
                                Circle()
                                    .frame(width:20, height:20)
                                    .foregroundColor(Color("MediumBlue"))
                                RoundedRectangle(cornerRadius: 5)
                                    .frame(width:60, height:30)
                                    .foregroundColor(Color("MediumBlue"))
                                    .padding(.leading,5)
                            }
                        }
                        
                        if let todayDaily = habit.sortedDaily.first(where: {
                            Calendar.current.isDate($0.date, inSameDayAs: Date())
                        }) {
                            HStack{
                                Text("\(todayDaily.count) / \(habit.goalCount)")
                                    .font(.system(size: cardWidth * 0.1, weight: .bold))
                                    .foregroundColor(Color("MediumBlue"))
                                    .padding(.top)
                                Spacer()
                            }
                            WaterFillView(progress: Binding(
                                get: { CGFloat(todayDaily.count) / CGFloat(habit.goalCount) },
                                set: { newValue in
                                    todayDaily.count = Int(newValue * CGFloat(habit.goalCount))
                                }
                            ))
                            .frame(width: cardWidth * 0.6)
                            .onTapGesture {
                                todayDaily.count = todayDaily.count+1
                            }
                            .onLongPressGesture{
                                if todayDaily.count > 0
                                {
                                    todayDaily.count = todayDaily.count-1
                                }
                            }
                            
                        }
                    }
                    .padding(20)
                }
                .padding(.top, -30)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    func backHabitView(habit: HabitData) -> some View {
        GeometryReader { geometry in
            let cardWidth = geometry.size.width * 0.9
            let cardHeight = geometry.size.height * 0.85

            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
//                    .shadow(radius: 5)

                VStack(spacing: 10) {
                    
                    Text("\(habit.startDate.toString()) ~ \(habit.endDate.toString())")
                        .font(.system(size: cardWidth * 0.04))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    
                    HStack{
                        VStack(spacing: 10) {
                            HStack{
                                Text("진행률")
                                    .font(.system(size: cardWidth * 0.05, weight: .bold))
                                    .foregroundColor(Color("StrongBlue-font"))
                                    .padding(.leading,20)
                                Spacer()
                            }
                            
                            let totalDays = max(1, daysDifference(date1: habit.startDate, date2: habit.endDate.addingTimeInterval(24 * 60 * 60)))
                            let elapsedDays = max(0, daysDifference(date1: habit.startDate, date2: min(Date(), habit.endDate).addingTimeInterval(24 * 60 * 60)))
                            let progressPercentage = String(format: "%.1f", Double(elapsedDays) / Double(totalDays) * 100)
                            HStack{
                                Text("\(progressPercentage)%")
                                    .font(.system(size: cardWidth * 0.09, weight:.bold))
                                    .foregroundColor(Color("LightBlue"))
                                    .padding(.leading,20)
                                Spacer()
                            }
                            HStack{
                                ProgressView(value: Double(elapsedDays), total: Double(totalDays))
                                    .progressViewStyle(LinearProgressViewStyle(tint: Color("LightBlue")))
                                    .frame(width: cardWidth * 0.6)
                                    .padding(.leading,20)
                                Spacer()
                            }
                        }
                        
                        //--------더미데이터로 보기 위해 여기부터-----------
                        
                        if let todayDaily = habit.sortedDaily.first(where: {
                            Calendar.current.isDateInToday($0.date)
                        }) {
                            NavigationLink(destination: FeedView(initialDate: Date(), habitID: habit.id)){
                                if let imageData = todayDaily.sortedDiary.first?.image{
                                    let uiImage = loadImage(from: imageData)
                                    if let convertedImage = uiImage{
                                        Image(uiImage: convertedImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: cardWidth * 0.3, height: cardWidth * 0.3)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .strokeBorder(AngularGradient(gradient:Gradient(colors:[.white, Color("LightBlue"), .white]), center:.center), lineWidth:5)
                                            )
                                            .padding(.trailing,20)
                                    }
                                }
                                else{
                                    NavigationLink(destination: FeedView(initialDate: Date(), habitID: habit.id)){
                                        HStack{
                                            Circle()
                                                .strokeBorder(AngularGradient(gradient:Gradient(colors:[.white, Color("LightBlue"), .white]), center:.center), lineWidth:5)
                                        }
                                        .frame(width:cardWidth * 0.3, height:cardWidth*0.3)
                                        .padding(.trailing,20)
                                    }
                                }
                            }
                            
                        }
                }
                    //---------여기까지 주석 처리 & 아래 주석 해제 ----------
//                        NavigationLink(destination: FeedView(habitID: habit.id)){
//                            Image("손톱1")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: cardWidth * 0.3, height: cardWidth * 0.3)
//                                .clipShape(Circle())
//                                .overlay(
//                                    Circle()
//                                        .strokeBorder(AngularGradient(gradient:Gradient(colors:[.white, Color("LightBlue"), .white]), center:.center), lineWidth:5)
//                                )
//                                .padding(.trailing,20)
//                        }
//                    }
                    // --------------------------------------------


                    // 연속 달성 표시
                    let consecutiveDays = habit.consecutiveAchievedDays()
                    HStack{
                        if consecutiveDays > 0 {
                            Text("🔥 \(consecutiveDays)일 연속 달성 중!")
                                .font(.system(size: cardWidth * 0.05, weight: .bold))
                                .foregroundColor(.orange)
                                .padding(.leading, 20)
                        } else {
                            Text("오늘의 목표를 달성해 보세요!")
                                .font(.system(size: cardWidth * 0.05, weight: .bold))
                                .foregroundColor(.orange)
                                .padding(.leading, 20)
                        }
                        Spacer()
                    }

                    // 최근 2주간의 기록
                    recentRecordSection(habit: habit, cardWidth: cardWidth, geometry: geometry)
                        .frame(width:cardWidth * 0.35, height:cardWidth * 0.4)
                        .padding(.top,30)
                }
                .padding(.top,-cardWidth * 0.1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // 좌우 반전 효과 추가
            .rotation3DEffect(
                .degrees(180),
                axis: (x: 0, y: 1, z: 0)
            )
        }
    }
    
    func loadImage(from imageData: Data?) -> UIImage? {
        guard let imageData = imageData else { return nil }
        return UIImage(data: imageData)
    }


    private func recentRecordSection(habit: HabitData, cardWidth: CGFloat, geometry: GeometryProxy) -> some View {
        ZStack {
            let dynamicHeight = selectedDate == nil ? geometry.size.height * 0.35 : geometry.size.height * 0.45

            RoundedRectangle(cornerRadius: 15)
                .fill(Color("MediumBlue"))
                .frame(width: geometry.size.width * 0.9, height: dynamicHeight)
                .animation(.easeInOut(duration: 0.3), value: selectedDate)

            VStack {
                Text("최근 2주간의 기록")
                    .font(.system(size: 18, weight: .bold))
                    .frame(width: cardWidth * 0.9, alignment: .topLeading)
                    .foregroundColor(.white)
                    .animation(.easeInOut(duration: 0.3), value: selectedDate)

                if let selectedDate = selectedDate,
                   let daily = habit.sortedDaily.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
                    dailyAdjustPanel(daily: daily, habit: habit)
                        .transition(.move(edge: .top))
                        .animation(.easeInOut(duration: 0.3), value: selectedDate)
                }

                // LazyVGrid로 날짜 기록
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 7),
                    spacing: 10
                ) {
                    ForEach(recentTwoWeeksDates(), id: \.self) { date in
                        let daily = habit.sortedDaily.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
                        let isCompleted = (habit.type == "고치고 싶은" && daily?.count ?? 0 <= habit.goalCount) || (habit.type == "만들고 싶은" && daily?.count ?? 0 >= habit.goalCount)

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
                .padding(.horizontal, 8)
                .transition(.move(edge: .bottom))
                .animation(.easeInOut(duration: 0.3), value: selectedDate)
            }
            .frame(width: geometry.size.width * 0.85, height: dynamicHeight)
        }
    }

    private func dailyAdjustPanel(daily: Daily, habit: HabitData) -> some View {
        VStack {
            HStack {
                Button(action: {
                    if daily.count > 0 {
                        daily.count -= 1
                        HabitManager.saveContext(modelContext)
                    }
                }) {
                    Text("-")
                        .font(.system(size:20))
                        .frame(width: 40, height: 40)
                        .background(Color.clear)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                
                Text("\(daily.count)")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                
                Button(action: {
                    daily.count += 1
                    HabitManager.saveContext(modelContext)
                }) {
                    Text("+")
                        .font(.system(size: 20))
                        .frame(width: 40, height: 40)
                        .background(Color.clear)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
            }
        }
        
        .frame(width:270, height:20)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color.black.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                        .foregroundColor(.white)
                )
        )
        .shadow(radius: 5)
        .padding(.horizontal, 10)
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
            .padding(10)
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
                    .frame(width: 240, height: 240)
        
                WaterShape(level: progress, waveOffset: waveOffset)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color("WashingMachine-water").opacity(0.1), Color("WashingMachine-water")]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: 240, height: 240)
                    .clipShape(Circle())
                    .animation(.easeInOut(duration: 0.8), value: progress)
                
                Circle()
                    .strokeBorder(Color("WashingMachine-line"), lineWidth: 10)
                    .background(Circle().fill(Color.clear))
                    .frame(width: 250, height: 250)
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
    SwiftMainView().modelContainer(for: [HabitData.self, Daily.self])
}


