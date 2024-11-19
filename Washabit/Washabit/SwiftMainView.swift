//
//  SwiftMainView.swift
//  Washabit
//
//  Created by 강현중 on 11/6/24.
//

import SwiftUI
import Foundation


struct HabitData:Identifiable {
    let id = UUID()
    let title: String // 제목
    let goal: Int // 목표횟수
    let description: String //설명
    let startDate : Date // 시작날짜
    let endDate : Date // 종료날짜
    var isFlipped = false // 앞뒷면
    var daily : [Daily] // 일별기록
}

struct Daily {
    var count: Int = 0 // 시행횟수
    var image: String // 이미지이름
    
    init(value: Int, imageName: String)
    {
        self.count = value
        self.image = imageName
    }
}

extension String {
    func toDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        return dateFormatter.date(from: self) ?? Date() // 실패 시 현재 날짜 반환
    }
}

extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        return dateFormatter.string(from: self)
    }
}

func recentTwoWeeksDates() -> [Date]
{
    let calendar = Calendar.current
    let today = Date()
    var dates: [Date]=[]
    
    for i in 0..<14
    {
        if let newDate = calendar.date(byAdding: .day, value: -i, to: today)
        {
            dates.append(newDate)
        }
    }
    dates.reverse()
    return dates
}

func formattedDate(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd"
    return formatter.string(from: date)
}

func daysDifference(date1: Date, date2: Date) -> Int
{
    let calendar = Calendar.current
    let ret = calendar.dateComponents([.day],from: date1, to:date2)
    return ret.day ?? 0
}



struct SwiftMainView: View {
    
    @State var habitData = [
        HabitData(title: "첫 번째 목표", goal:5, description: "이것은 첫 번째 항목에 대한 설명입니다.", startDate: "2024-11-11".toDate() ,endDate: "2024-11-20".toDate(), daily: Array(repeating: Daily(value: 0, imageName : "exampleimage"), count: max(1,daysDifference(date1: "2024-11-11".toDate(), date2:"2024-11-20".toDate())+1))),
        HabitData(title: "두 번째 목표", goal:6, description: "이것은 두 번째 항목에 대한 설명입니다.",startDate: "2024-11-11".toDate() ,endDate: "2024-11-30".toDate(), daily: Array(repeating: Daily(value: 0, imageName : "exampleimage"), count: max(1,daysDifference(date1: "2024-11-11".toDate(), date2:"2024-11-30".toDate())+1))),
        HabitData(title: "세 번째 목표", goal:6, description: "이것은 세 번째 항목에 대한 설명입니다.",startDate: "2024-11-11".toDate() ,endDate: "2024-12-30".toDate(), daily: Array(repeating: Daily(value: 0, imageName : "exampleimage"), count: max(1,daysDifference(date1: "2024-11-11".toDate(), date2:"2024-12-30".toDate())+1)))
    ]
    
    // UI
    @State private var selectedTab = 0
    var body: some View {
        Button("Button") {
            /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
        }.offset(x: 140, y: -10)
        Button("New Habit") {
            /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
        }.offset(x: 140, y: 450)
        
        TabView {
            ForEach(habitData.indices, id:\.self) { index in
                ZStack{  //앞 뒷면 컨텐츠를 Z스택으로 구분
                    if !habitData[index].isFlipped
                    {
                        Rectangle()
                            .fill(Color.gray.opacity(0.1)) // 배경 색 설정
                            .frame(width: 400, height: 400)
                            .overlay{
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 200, height: 200)
                                    .onTapGesture {
                                        habitData[index].daily[1].count += 1
                                    }
                                    .onLongPressGesture
                                {
                                    if habitData[index].daily[1].count  > 0
                                    {
                                        habitData[index].daily[1].count += -1
                                    }
                                }
                                Spacer()
                                Text(habitData[index].title)
                                    .font(.title)
                                    .padding()
                                    .offset(x:-60, y:-140)
                                Text("\(habitData[index].daily[1].count) / \(habitData[index].goal)") // 위치 조절 필요
                                    .font(.body)
                                    .padding()
                                    .offset(x:-100, y:-100)
                            }
                    }
                    else // 뒷면
                    {
                        Rectangle()
                            .fill(Color.gray.opacity(0.1)) // 배경 색 설정
                            .frame(width: 400, height: 400)
                            .overlay{
                                let totalDays = max(1, daysDifference(date1: habitData[index].startDate, date2: habitData[index].endDate) + 1) // 전체 기간
                                let elapsedDays = max(0, daysDifference(date1: habitData[index].startDate, date2: Date()) + 1) // 지난 기간
                                ProgressView(value: Double(elapsedDays), total: Double(totalDays))
                                    .progressViewStyle(LinearProgressViewStyle(tint: .red))
                                    .padding()
                                    .offset(x: -50, y: -130)
                                    .frame(width: 240, height: 100)
                                
                                Image(habitData[index].daily[1].image)
                                    .resizable()
                                    .frame(width: 150,height: 150)
                                    .offset(x:80,y:-35)
                                    .padding()
                                    .onTapGesture {
                                        //do nothing
                                    }
                                let percentage = String(format: "%.1f%", Double(elapsedDays) / Double(totalDays)*100)
                                Text("\(percentage)%")
                                    .font(.title)
                                    .padding()
                                    .offset(x:-90, y:-80)
                                let tmp1 = habitData[index].startDate.toString()
                                let tmp2 = habitData[index].endDate.toString()
                                Text("\(tmp1) \n~ \(tmp2)")
                                    .font(.body)
                                    .padding()
                                    .offset(x:-90, y:-30)
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                                                ForEach(recentTwoWeeksDates(), id: \.self) { date in Text(formattedDate(date: date)) // 날짜 표시
                                                            .frame(width: 40, height: 40) // 버튼 크기
                                                            .background(Color.blue)
                                                            .foregroundColor(.white)
                                                            .cornerRadius(8)
                                                }
                                            }
                                .offset(x : 0, y:100)
                                .frame(width:300, height: 300)
                            }.rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)) //정방향으로 보이게
                    }
                }
                .rotation3DEffect(
                    .degrees(habitData[index].isFlipped ? 180 : 0), // 카드가 뒤집힐 각도
                    axis: (x: 0, y: 1, z: 0), // y축을 기준으로 회전
                    perspective: 0.5 // 3D 효과의 깊이 조정
                )
                .animation(.easeInOut(duration: 0.6), value: habitData[index].isFlipped)
                .frame(maxWidth: 350, maxHeight: 350)
                .cornerRadius(30)
                .padding()
                .onTapGesture {
                    withAnimation
                    {
                        habitData[index].isFlipped.toggle()
                    }
                }
            }
        }
        .frame(width: 350, height: 420)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
    }
}

#Preview {
    SwiftMainView()
}
