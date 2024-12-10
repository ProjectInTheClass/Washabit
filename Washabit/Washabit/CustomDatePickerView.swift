import SwiftUI

struct CustomDatePickerView: View {
    @State var startDate: Date? = nil
    @State var endDate: Date? = nil
    @State private var selectedMonth: Date = Date()
    
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
                    Text("\(Calendar.current.component(.day, from: date))")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(5)
                        .background(
                            backgroundColor(for: date)
                        )
                        .cornerRadius(10)
                        .onTapGesture {
                            selectDate(date)
                        }
                }
            }
            .padding([.trailing,.leading], 20)
        }
    }
    
    private func backgroundColor(for date: Date) -> Color {
        guard let startDate = startDate else { return Color.clear }
        
        if let endDate = endDate {
            // 범위 내에 있는 날짜는 파란색 배경
            if date >= startDate && date <= endDate {
                return Color.blue.opacity(0.2)
            }
        } else if date == startDate {
            return Color.blue.opacity(0.5) // 시작 날짜는 진한 파란색
        }
        
        return Color.clear
    }
    
    private func selectDate(_ date: Date) {
        if startDate == nil {
            startDate = date
        } else if let start = startDate, let end = endDate {
            startDate = date
            endDate = nil
        } else if let start = startDate, endDate == nil {
            if date >= start {
                endDate = date
            } else {
                startDate = date
            }
        }
    }
}

extension Calendar {
    func startOfMonth(for date: Date) -> Date? {
        return self.date(from: self.dateComponents([.year, .month], from: date))
    }
}

struct CustomDatePickerView_Previews: PreviewProvider {
    static var previews: some View {
        CustomDatePickerView()
    }
}

