//
//  FinishedHabitView.swift
//  Washabit
//
//  Created by JangWooJeong on 12/23/24.
//

import SwiftUI
import SwiftData

struct FinishedHabitView: View {
    @Environment(\.presentationMode) var presentationMode
    @Query private var habits: [HabitData]
    let habitID: UUID
    private var habit: HabitData? {
        habits.first(where: { $0.id == habitID })
    }
    @State private var progress: CGFloat = 0.85
    @State private var type: String = ""
    
    
    var body:some View{
        ZStack{
            Color(Color("MainColor"))
            VStack(alignment:.leading){
                Button{
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    HStack{
                        ZStack{
                            Color(.white)
                            Image("Icons/drawer")
                        }
                        .frame(width:38, height:38)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 2)
                        Spacer()
                    }
                    .padding(.bottom,20)
                    .padding(.leading,5)
                }
                if let habit = habit {
                    Text("\(habit.title)")
                        .font(.system(size:20, weight:.bold))
                        .foregroundColor(Color("StrongGray-font"))
                        .padding(.leading,5)
                    Text("\(formatDate(habit.startDate)) ~ \(formatDate(habit.endDate))")
                        .font(.system(size:14))
                        .foregroundColor(Color("StrongGray-font"))
                        .padding(.leading,5)
                }
                else {
                    // 습관이 없음.?
                }
                
                ZStack{
                    Color(.white)
                    HStack{
                        VStack{
                            HStack{
                                if type == "success" {
                                    Image("Icons/checkmark")
                                        .resizable()
                                        .frame(width:16, height:14)
                                        .padding(.leading,5)
                                }
                                else{
                                    Image("Icons/cross")
                                        .resizable()
                                        .frame(width:14, height:14)
                                        .padding(.leading,5)
                                }
                                Spacer()
                                HStack(spacing:5){
                                    Circle()
                                        .frame(width:12,height:12)
                                        .foregroundColor(type == "success" ? Color("StrongBlue-font") : Color("StrongRed"))
                                    Circle()
                                        .frame(width:12, height:12)
                                        .foregroundColor(type == "success" ? Color("StrongBlue-font") : Color("StrongRed"))
                                    
                                    Rectangle()
                                        .frame(width:30, height:15)
                                        .cornerRadius(3)
                                        .foregroundColor(type == "success" ? Color("StrongBlue-font") : Color("StrongRed"))
                                }
                                
                            }
                            WaterFillView(progress:$progress, type:$type)
                        }
                        .frame(width:110, height:130)
                        .padding(.leading,15)
                        
                        Spacer()
                        
                        if let habit = habit {
                            let calendar = Calendar.current
                            let daysDiff = calendar.dateComponents([.day], from: habit.startDate, to: habit.endDate).day ?? 0
                            VStack{
                                Text("\(daysDiff + 1) 일간의 습관 \(habit.type == "고치고 싶은" ? "고치기" : "만들기") 도전!")
                                    .font(.system(size:14, weight:.bold))
                                HStack{
                                    if habit.type == "고치고 싶은"{
                                        Text("😆 최저 기록")
                                            .font(.system(size:14, weight:.bold))
                                            .padding(.leading,8)
                                        Spacer()
                                        Text("\(habit.habitInformations(habit:habit).minCount)회")
                                            .font(.system(size:14))
                                            .padding(.trailing,8)
                                    }
                                    else{
                                        Text("😆 최고 기록")
                                            .font(.system(size:14, weight:.bold))
                                            .padding(.leading,8)
                                        Spacer()
                                        Text("\(habit.habitInformations(habit:habit).maxCount)회")
                                            .font(.system(size:14))
                                            .padding(.trailing,8)
                                    }
                                }
                                .padding(.top,5)
                                
                                HStack{
                                    if habit.type == "고치고 싶은"{
                                        Text("🥲 최고 기록")
                                            .font(.system(size:14, weight:.bold))
                                            .padding(.leading,8)
                                        Spacer()
                                        Text("\(habit.habitInformations(habit:habit).maxCount)회")
                                            .font(.system(size:14))
                                            .padding(.trailing,8)
                                    }
                                    else{
                                        Text("🥲 최저 기록")
                                            .font(.system(size:14, weight:.bold))
                                            .padding(.leading,8)
                                        Spacer()
                                        Text("\(habit.habitInformations(habit:habit).minCount)회")
                                            .font(.system(size:14))
                                            .padding(.trailing,8)
                                    }
                                }
//                                HStack{
//                                    Text("🔥  연속 달성 최장기록")
//                                        .font(.system(size:12, weight:.bold))
//                                        .padding(.leading,8)
//                                    Spacer()
//                                    Text("15일")
//                                        .font(.system(size:14))
//                                        .padding(.trailing,8)
//                                }
                            }
                            .frame(width:170, height:130)
                            .padding(.trailing,15)
                        }
                    }
                }
                .frame(width:330, height:150)
                .cornerRadius(15)
                .shadow(color:Color.black.opacity(0.15), radius:6, x:0, y:2)
                .padding(.top,10)
                .padding(.leading,5)
                
                if let habit = habit{
                    FeedGalleryView(habit)
                }
            }
            .padding(30)
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .onAppear {
            updateHabitType()
        }
    }
    
    struct WaterFillView: View {
        @Binding var progress: CGFloat
        @Binding var type:String
        @State private var waveOffset: CGFloat = 0.0
        @State private var timer: Timer?

        var body: some View {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 100, height: 100)
        
                WaterShape(level: progress, waveOffset: waveOffset)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: type == "success" ? [Color("WashingMachine-water").opacity(0.1), Color("WashingMachine-water")] : [Color("StrongRed").opacity(0.1), Color("StrongRed").opacity(0.5)]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .animation(.easeInOut(duration: 0.8), value: progress)
                ZStack{
                    Circle()
                        .strokeBorder(type == "success" ? Color("WashingMachine-line") : Color("MediumRed").opacity(0.4), lineWidth: 5)
                        .background(Circle().fill(Color.clear))
                        .frame(width: 105, height: 105)
                    Text("\(Int(progress * 100))%")
                        .font(.system(size:18, weight:.bold))
                        .foregroundColor(type == "success" ? Color("MediumBlue") : Color("MediumRed"))
                }
                Rectangle()
                    .frame(width:6, height:18)
                    .cornerRadius(4)
                    .foregroundColor(type == "success" ? Color("MediumBlue") : Color("MediumRed"))
                    .padding(.leading,90)
                    
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
                let yOffset = sin(relativeX * .pi * 2 + waveOffset) * 5
                path.addLine(to: CGPoint(x: CGFloat(x), y: waterHeight + yOffset))
            }
            
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.closeSubpath()
            
            return path
        }
    }
    
    func FeedGalleryView(_ habit:HabitData) -> some View{
        ScrollView() { // 스크롤 가능한 화면
            let columns = [
                GridItem(.flexible()), // 첫 번째 컬럼
                GridItem(.flexible()), // 두 번째 컬럼
                GridItem(.flexible())  // 세 번째 컬럼
            ]
            LazyVGrid(columns: columns, spacing:20) { // 3개의 열, 각 열 간 간격 20
//                ForEach(0...6, id: \.self) { _ in
                ForEach(habit.sortedDaily){ daily in
                    let calendar = Calendar.current
                    let month = calendar.component(.month, from: daily.date)
                    let day = calendar.component(.day, from: daily.date)
                    NavigationLink(destination:FeedView(initialDate: daily.date, habitID: habit.id)){
                        VStack {
                            ZStack{
                                Rectangle()
                                    .frame(width:90, height:90)
                                    .cornerRadius(15)
                                    .foregroundColor(Color(.white))
                                    .shadow(color:Color.black.opacity(0.15), radius:6, x:0, y:2)
                                if let uiImage = loadImage(from: daily.diary?.first?.image) {
                                    Image(uiImage:uiImage)
                                        .resizable()
                                        .frame(width:80, height:80)
                                        .cornerRadius(14)
                                }
                                VStack{
                                    Text("\(month)월")
                                        .font(.system(size:16, weight:.bold))
                                        .foregroundColor(Color("StrongGray-font"))
                                    Text("\(day)일")
                                        .font(.system(size:16, weight:.bold))
                                        .foregroundColor(Color("StrongGray-font"))
                                }
                            }
                        }
                    }
                }
            }
        }
        .frame(width:330, height:330)
        .padding(.top,10)
        .padding(.leading,4)
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd" // 원하는 포맷 지정
        return formatter.string(from: date)
    }
    
    func loadImage(from imageData: Data?) -> UIImage? {
        guard let imageData = imageData else { return nil }
        return UIImage(data: imageData)
    }
    
    private func updateHabitType() {
        if let habit = habit {
            type = isHabitSucceeded(habit: habit) ? "success" : "fail"
        } else {
            type = "fail" // 습관 데이터를 찾지 못한 경우 기본값
        }
    }
    
    func isHabitSucceeded(habit: HabitData) -> Bool {
        let calendar = Calendar.current
        var successDay = 0
        let totalDay = calendar.dateComponents([.day], from: habit.startDate, to: habit.endDate).day ?? 0

        for daily in habit.daily {
            if habit.type == "고치고 싶은" {
                if daily.count <= habit.goalCount {
                    successDay += 1
                }
            } else {
                if daily.count >= habit.goalCount {
                    successDay += 1
                }
            }
        }

        if totalDay == 0 {
            return false
        }

        progress = CGFloat(Double(successDay) / Double(totalDay+1))
        print("\((Double(successDay) / Double(totalDay+1)) * 100)")
        return (Double(successDay) / Double(totalDay + 1)) * 100 >= Double(habit.goalPercentage)
    }
}

//#Preview{
//    FinishedHabitView()
//}
