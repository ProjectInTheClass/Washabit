import SwiftUI

struct WeeklyCalendarView: View {
    @State private var currentWeek: Date = Date()
    private let daysOfWeek = ["일", "월", "화", "수", "목", "금", "토"]

    var body: some View {
        VStack(spacing: 16) {
            // 상단 월 표시 및 버튼
            HStack {
                Button(action: { changeWeek(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                        .padding(8)
                }
                Spacer()
                Text(currentMonth)
                    .font(.headline)
                    .foregroundColor(.gray)
                Spacer()
                Button(action: { changeWeek(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                        .padding(8)
                }
            }

            // 주간 요일 및 날짜 표시
            HStack(spacing: 8) {
                ForEach(weekDates, id: \.self) { date in
                    VStack {
                        Text(daysOfWeek[calendar.component(.weekday, from: date) - 1]) // 요일
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("\(calendar.component(.day, from: date))") // 날짜
                            .font(.title3)
                            .foregroundColor(isToday(date) ? .blue : .primary)
                            .bold(isToday(date))
                    }
                    .frame(maxWidth: .infinity) // 균등 배치
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 130)
        .background(.white)
        .cornerRadius(10)
    }

    // 현재 월 표시
    private var currentMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy" // 예: "November 2024"
        return formatter.string(from: currentWeek)
    }

    // 해당 주의 날짜 계산
    private var weekDates: [Date] {
        let startOfWeek = calendar.dateInterval(of: .weekOfMonth, for: currentWeek)?.start ?? Date()
        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: startOfWeek)
        }
    }

    // 오늘 날짜인지 확인
    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    // 주 변경 함수
    private func changeWeek(by value: Int) {
        guard let newWeek = calendar.date(byAdding: .weekOfMonth, value: value, to: currentWeek) else { return }
        withAnimation {
            currentWeek = newWeek
        }
    }

    // 캘린더 설정
    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // 월요일 시작
        return calendar
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyCalendarView()
    }
}

