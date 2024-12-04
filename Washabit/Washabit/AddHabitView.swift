//
//  AddHabitView.swift
//  Washabit
//
//  Created by JangWooJeong on 11/6/24.
//

import SwiftUI

struct AddHabitView: View {
    @Environment(\.modelContext) private var modelContext
    @State var title:String = ""
    @State private var selectedOption: String? = "고치고 싶은"
    @State private var date = Date()
    @State private var totalHabitCount:Int = 30
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

       var backButton : some View {  // <-- 👀 커스텀 버튼
           Button{
               self.presentationMode.wrappedValue.dismiss()
           } label: {
               HStack {
                   Image(systemName: "chevron.left")
                       .font(.system(size: 18, weight: .bold))
                       .foregroundColor(Color("StrongBlue-font"))
               }
           }
       }
        
    let options = ["고치고 싶은", "만들고 싶은"]
    @State private var selectedCount: Int = 1
        let numOptions = Array(1...100)
    @State private var selectedPercentage: Int = 50
        let percentageOptions = [50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100]
    
    @State private var showCountPicker: Bool = false
    var body: some View {
        ZStack {
            Color("MainColor")
            VStack{
                HStack{
                    Button{
                        self.presentationMode.wrappedValue.dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color("StrongBlue-font"))
                        }
                    }
                    Spacer()
                }
                .padding([.top,.leading],20)
                ZStack{
                    Text("새 목표 추가하기")
                        .foregroundColor(Color("StrongBlue-font"))
                        .bold()
                        .frame(width:300, alignment: .leading)
                }
                .padding(10)
                ZStack{
                    TextField("제목 입력하기", text:$title)
                        .padding()
                        .frame(width:327, height:62)
                        .background(Color(.white))
                        .cornerRadius(12)
                    HStack{
                        Spacer()
                        Text("\(totalHabitCount)번째 목표")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width:85, height:28)
                            .background(Color("StrongBlue-comp"))
                            .cornerRadius(6)
                    }
                    .padding(.trailing, 40)
                }
                ZStack{
                    Text("목표 설정하기")
                        .foregroundColor(Color("StrongBlue-font"))
                        .bold()
                        .frame(width:300, alignment: .leading)
                }
                .padding(10)
                    
                ZStack(alignment: .topLeading){
                    Color(.white)
                    VStack(alignment: .leading){
                        Text("습관 유형")
                            .padding([.top,.leading],20)
                            .bold()
                            .font(.system(size: 15))
                        HStack(spacing:25){
                            Spacer()
                            ForEach(options, id:\.self){ option in
                                HStack(spacing:15){
                                    Text(option)
                                        .foregroundColor(Color.black)
                                        .font(.system(size: 14))
                                    Circle()
                                        .stroke(Color("LightGray"))
                                        .frame(width:18, height:18)
                                        .overlay(
                                            Circle()
                                                .fill(Color("LightBlue"))
                                                .frame(width:10, height:10)
                                                .opacity(selectedOption == option ? 1 : 0)
                                        )
                                }
                                .onTapGesture {
                                    selectedOption = option
                                    print("Selected: \(selectedOption!)")
                                }
                            }
                            Spacer()
                        }
                        .padding([.top,.bottom],10)
                        Text("목표 기간")
                            .padding(.leading, 20)
                            .padding(.bottom, 10)
                            .bold()
                            .font(.system(size: 15))
                        CustomDatePickerView()
                    
                        HStack{
                            Text(selectedOption == "고치고 싶은" ? "하루 제한 횟수" : "하루 실행 횟수")
                                .padding(.leading, 20)
                                .bold()
                                .font(.system(size: 15))
                            Spacer()
                            
                            Menu {
                                ForEach(numOptions, id: \.self) { option in
                                    Button(action: {
                                        selectedCount = option
                                        }) {
                                            Text("\(option)회")
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text("\(selectedCount)회")
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(Color("StrongBlue-font"))
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(Color("StrongBlue-font"))
                                    }
                                    .padding(.trailing, 20)
                            }
                        }
                        .padding([.top,.bottom], 15)
                        HStack{
                            Text("목표 달성률")
                                .padding(.leading, 20)
                                .bold()
                                .font(.system(size: 15))
                        Spacer()
                            Menu {
                                ForEach(percentageOptions, id: \.self) { option in
                                    Button(action: {
                                        selectedPercentage = option
                                        }) {
                                            Text("\(option)%")
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text("\(selectedPercentage)%")
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(Color("StrongBlue-font"))
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(Color("StrongBlue-font"))
                                    }
                                    .padding(.trailing, 20)
                                }
                        }
                    }
                    
                }
                .frame(width:327, height:450, alignment: .leading)
                .cornerRadius(15)
                HStack{
                    Spacer()
                    Button{
                        HabitManager.addNewHabit(
                            title,
                            selectedCount,
                            Date(),
                            Date().addingTimeInterval(3 * 24 * 60 * 60),
                            to: modelContext
                        )
                        self.presentationMode.wrappedValue.dismiss()
                    }
                label: {
                    Circle()
                        .fill(Color(.white))
                        .frame(width:66, height:66)
                        .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 2)
                        .overlay(
                            
                            HStack {
                                Image(systemName:"checkmark")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color("StrongBlue-font"))
                            }
                        )
                }}
                .padding(.trailing,20)
                .padding(.top,10)
            }
            .padding()
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    AddHabitView()
}
