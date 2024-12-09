import SwiftUI

struct ExpandableCalendar: View {
    @State private var isMonthlyView: Bool = false // 현재 월간 보기인지 여부
    @State private var currentMonth: Date = Date() // 현재 달력 기준 날짜
    @State private var currentWeek: Date = Date()
    @State private var tabIndex = 1

    var body: some View {
        VStack {
            // 캘린더 박스
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)

                VStack(spacing: 8) {
                    HStack{
                        Text(currentMonthTitle)
                            .font(.headline)
                            .padding(.leading,15)
                        Spacer()
                        Button(action: {
                            withAnimation{
                                isMonthlyView.toggle()
                            }
                        }) {
                            Image(systemName: isMonthlyView ? "chevron.up" : "chevron.down")
                                .foregroundColor(.gray)
                                .font(.system(size: 14))
                        }
                    }
                    .padding(.trailing, 15)
                    
//                    HStack {
//                        Button(action: { changeMonth(by: -1) }) {
//                            Image(systemName: "chevron.left")
//                                .foregroundColor(.blue)
//                        }
//                        Spacer()
//                        Text(currentMonthTitle)
//                            .font(.headline)
//                        Spacer()
//                        Button(action: { changeMonth(by: 1) }) {
//                            Image(systemName: "chevron.right")
//                                .foregroundColor(.blue)
//                        }
//                    }
//                    .padding(10)
                    HStack{
                        // 날짜 표시
                        TabView(selection:$tabIndex){
                            ForEach(0..<3, id:\.self){ index in
                                if isMonthlyView {
                                    MonthlyView(currentMonth: currentMonth)
                                        .tag(index)
                                }
                                else{
                                    WeeklyView(currentWeek: currentWeek)
                                        .tag(index)
                                }
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .onChange(of:tabIndex){newValue in
                            if newValue == 0{
                                if isMonthlyView {
                                    changeMonth(by: -1)
                                }
                                else{
                                    changeWeek(by: -1)
                                }
                                tabIndex=1
                            }
                            else if newValue == 2{
                                if isMonthlyView{
                                    changeMonth(by: 1)
                                }
                                else {
                                    changeWeek(by: 1)
                                }
                                tabIndex=1
                            }
                        }
                    }
                }
                .padding()
            }
            .frame(height: isMonthlyView ? 330 : 100) // 높이 조정
            .animation(.easeInOut(duration: 0.5), value: isMonthlyView) // 크기 변화 애니메이션
        }
        .padding()
        .onChange(of: currentWeek) { newWeek in
            // currentWeek가 변경되었을 때 currentMonth 동기화
            currentMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: newWeek)) ?? Date()
        }
        .onChange(of:currentMonth){newMonth in
            currentWeek = Calendar.current.date(from:Calendar.current.dateComponents([.year, .month], from: newMonth)) ?? Date()
        }
    }

    private var currentMonthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 MM월"
        return formatter.string(from: isMonthlyView ? currentMonth : currentWeek)
    }

    private func changeMonth(by value: Int) {
        currentMonth = Calendar.current.date(byAdding: .month, value: value, to: currentMonth) ?? Date()
    }
    private func changeWeek(by value:Int){
        currentWeek = Calendar.current.date(byAdding: .weekOfMonth, value:value, to:currentWeek) ?? Date()
    }
}

struct WeeklyView: View {
    let currentWeek: Date
    private let daysOfWeek = ["일", "월", "화", "수", "목", "금", "토"]

    var body: some View {
        VStack{
            // 요일 헤더
            HStack(spacing: 8) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.gray)
                }
            }
            
            // 주간 날짜
            HStack(spacing: 8) {
                ForEach(currentWeekDates, id: \.self) { date in
                    VStack {
                        Text("\(Calendar.current.component(.day, from: date))")
                            .font(.title3)
                            .foregroundColor(isToday(date) ? .blue : .primary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private var currentWeekDates: [Date] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfMonth, for: currentWeek)?.start ?? Date()
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }

    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
}

struct MonthlyView: View {
    let currentMonth: Date
    private let daysOfWeek = ["일", "월", "화", "수", "목", "금", "토"]

    var body: some View {
        VStack(spacing: 8) {
            // 요일 헤더
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.gray)
                }
            }

            // 월간 날짜
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                ForEach(monthDates, id: \.self) { date in
                    Text("\(Calendar.current.component(.day, from: date))")
                        .font(.body)
                        .foregroundColor(isWithinCurrentMonth(date) ? .primary : .gray)
                        .padding(5)
                        .background(isToday(date) ? Color.blue.opacity(0.3) : Color.clear)
                        .cornerRadius(8)
                }
            }
        }
        .padding(.top)
    }

    private var monthDates: [Date] {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        let startWeekday = calendar.component(.weekday, from: startOfMonth) - 1
        let days = (1...range.count).compactMap {
            calendar.date(byAdding: .day, value: $0 - 1, to: startOfMonth)
        }
        let leadingDays = (0..<startWeekday).compactMap {
            calendar.date(byAdding: .day, value: -startWeekday + $0, to: startOfMonth)
        }
        let trailingDays = (0..<(7 - (days.count + startWeekday) % 7)).compactMap {
            calendar.date(byAdding: .day, value: $0 + 1, to: days.last!)
        }
        return leadingDays + days + trailingDays
    }

    private func isWithinCurrentMonth(_ date: Date) -> Bool {
        Calendar.current.isDate(date, equalTo: currentMonth, toGranularity: .month)
    }

    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
}

#Preview {
    ExpandableCalendar()
}
