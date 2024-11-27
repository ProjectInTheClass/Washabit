//
//  CustomCalendar.swift
//  Washabit
//
//  Created by JangWooJeong on 11/19/24.
//

import SwiftUI

struct CustomCalendar: View {
    @State private var date = Date()
    @State private var startDate = Date()
    @State private var endDate = Date()
    var body: some View {
        ZStack{
            Color(.white)
            DatePicker(
                "calendar",
                selection: $date,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
        }
        .frame(width:330, height:325)
        .cornerRadius(15)
    }
}

#Preview {
    CustomCalendar()
}
