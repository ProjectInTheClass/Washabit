import SwiftUI

struct CustomDatePickerView: View {
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    @State private var selectedMonth: Date = Date()
    
    private var today: Date{
        Calendar.current.startOfDay(for: Date())
    }
    
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter
    }
    
    private var daysInMonth: [Date] {
        var days: [Date] = []
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: selectedMonth)!
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: calendar.startOfMonth(for: selectedMonth)!) {
                days.append(date)
            }
        }
        
        return days
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    selectedMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth)!
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color("StrongBlue-font"))
                }
                Spacer()
                Text("\(monthFormatter.string(from: selectedMonth))")
                    .font(.headline)
                    .foregroundColor(Color("StrongBlue-font"))
                Spacer()
                Button(action: {
                    selectedMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth)!
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color("StrongBlue-font"))
                }
            }
            .padding([.leading, .trailing], 30)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(daysInMonth, id: \.self) { date in
                    let isBeforeToday = date < today
                    Text("\(Calendar.current.component(.day, from: date))")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(5)
                        .background(
                            Circle()
                                .fill(backgroundColor(for: date))
                        )
                        .foregroundColor(isBeforeToday ? Color.gray.opacity(0.5) : Color("StrongGray-font"))
                        .onTapGesture {
                            if !isBeforeToday {
                                selectDate(date)
                            }
                        }
                }
            }
            .padding([.trailing,.leading], 20)
        }
    }
    
    private func backgroundColor(for date: Date) -> Color {
        if let endDate = endDate {
            // 범위 내에 있는 날짜는 파란색 배경
            if date > today && date < endDate {
                return Color("LightBlue").opacity(0.44)
            }
            else if date == today || date == endDate {
                return Color("LightBlue").opacity(0.8)
            }
        } else if date == today {
            return Color("LightBlue").opacity(0.8) // 시작 날짜는 진한 파란색
        }
        
        return Color.clear
    }
    
    private func selectDate(_ date: Date) {
        if startDate == nil {
            startDate = today
        } else if let start = startDate, let end = endDate {
            endDate = date
        } else if let start = startDate, endDate == nil {
            if date >= start {
                endDate = date
            } else {
                startDate = today
            }
        }
    }
}

extension Calendar {
    func startOfMonth(for date: Date) -> Date? {
        return self.date(from: self.dateComponents([.year, .month], from: date))
    }
}
