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
//    @Binding var habitID: UUID
    @State private var progress: CGFloat = 0.85
    @State private var type: String = "success"
    
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
                
                Text("30분 운동하기")
                    .font(.system(size:20, weight:.bold))
                    .foregroundColor(Color("StrongGray-font"))
                    .padding(.leading,5)
                Text("2024.11.22 ~ 2024.12.20")
                    .font(.system(size:14))
                    .foregroundColor(Color("StrongGray-font"))
                    .padding(.leading,5)
                
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
                                Spacer()
                                HStack(spacing:5){
                                    Circle()
                                        .frame(width:12,height:12)
                                        .foregroundColor(Color("StrongBlue-font"))
                                    Circle()
                                        .frame(width:12, height:12)
                                        .foregroundColor(Color("StrongBlue-font"))
                                    
                                    Rectangle()
                                        .frame(width:30, height:15)
                                        .cornerRadius(3)
                                        .foregroundColor(Color("StrongBlue-font"))
                                }
                                
                            }
                            WaterFillView(progress:$progress, type:$type)
                        }
                        .frame(width:110, height:130)
                        .padding(.leading,15)
                        
                        Spacer()
                        
                        VStack{
                            Text("32일간의 습관 만들기 도전!")
                                .font(.system(size:14, weight:.bold))
                            HStack{
                                Text("😆 최고 기록")
                                    .font(.system(size:14, weight:.bold))
                                    .padding(.leading,8)
                                Spacer()
                                Text("3회")
                                    .font(.system(size:14))
                                    .padding(.trailing,8)
                            }
                            .padding(.top,5)
                            
                            HStack{
                                Text("🥲 최저 기록")
                                    .font(.system(size:14, weight:.bold))
                                    .padding(.leading,8)
                                Spacer()
                                Text("0회")
                                    .font(.system(size:14))
                                    .padding(.trailing,8)
                            }
                            HStack{
                                Text("🔥  연속 달성 최장기록")
                                    .font(.system(size:12, weight:.bold))
                                    .padding(.leading,8)
                                Spacer()
                                Text("15일")
                                    .font(.system(size:14))
                                    .padding(.trailing,8)
                            }
                        }
                        .frame(width:170, height:130)
                        .padding(.trailing,15)
                    }
                }
                .frame(width:330, height:150)
                .cornerRadius(15)
                .shadow(color:Color.black.opacity(0.15), radius:6, x:0, y:2)
                .padding(.top,10)
                .padding(.leading,5)
                
                FeedGalleryView()
            }
            .padding(30)
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
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
                        gradient: Gradient(colors: [Color("WashingMachine-water").opacity(0.1), Color("WashingMachine-water")]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .animation(.easeInOut(duration: 0.8), value: progress)
                ZStack{
                    Circle()
                        .strokeBorder(Color("WashingMachine-line"), lineWidth: 5)
                        .background(Circle().fill(Color.clear))
                        .frame(width: 105, height: 105)
                    Text("\(Int(progress * 100))%")
                        .font(.system(size:18, weight:.bold))
                        .foregroundColor(Color("MediumBlue"))
                }
                Rectangle()
                    .frame(width:6, height:18)
                    .cornerRadius(4)
                    .foregroundColor(Color("MediumBlue"))
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
    
    func FeedGalleryView() -> some View{
        ScrollView() { // 스크롤 가능한 화면
            let columns = [
                GridItem(.flexible()), // 첫 번째 컬럼
                GridItem(.flexible()), // 두 번째 컬럼
                GridItem(.flexible())  // 세 번째 컬럼
            ]
            LazyVGrid(columns: columns, spacing:20) { // 3개의 열, 각 열 간 간격 20
                ForEach(0...6, id: \.self) { _ in
                    VStack {
                        ZStack{
                            Rectangle()
                                .frame(width:90, height:90)
                                .cornerRadius(15)
                                .foregroundColor(Color(.white))
                                .shadow(color:Color.black.opacity(0.15), radius:6, x:0, y:2)
                            Image("sample_image")
                                .resizable()
                                .frame(width:80, height:80)
                                .cornerRadius(14)
                            VStack{
                                Text("11월")
                                    .font(.system(size:16, weight:.bold))
                                    .foregroundColor(Color("StrongGray-font"))
                                Text("24일")
                                    .font(.system(size:16, weight:.bold))
                                    .foregroundColor(Color("StrongGray-font"))
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
}

#Preview{
    FinishedHabitView()
}
