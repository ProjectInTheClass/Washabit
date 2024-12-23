//
//  GalleryView.swift
//  Washabit
//
//  Created by JangWooJeong on 12/21/24.
//

import SwiftUI
import SwiftData

struct GalleryView: View {
    @Environment(\.presentationMode) var presentationMode
    @Query private var habits:[HabitData]
    
    var body:some View{
        ZStack{
            Color("MainColor")
            VStack(alignment: .leading){
                Button{
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    HStack{
                        ZStack{
                            Color(.white)
                            Image("Icons/home")
                        }
                        .frame(width:38, height:38)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 2)
                        Spacer()
                    }
                    .padding(.leading,10)
                }
                Text("완료된 습관")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color("StrongGray-font"))
                    .padding(.top,15)
                    .padding(.leading,10)
                Text("달성기간이 지난 습관들이에요.")
                    .font(.system(size:13))
                    .foregroundColor(Color("StrongGray-font"))
                    .padding(.leading,10)
                
                GridView()
                
            }
            .padding(30)
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
    }
    
    func GridView()-> some View{
        ScrollView() { // 스크롤 가능한 화면
            let finishedHabits = habits.first?.finishedHabits(from: habits)
            if (finishedHabits ?? []).count > 0{
                let columns = [
                    GridItem(.flexible()), // 첫 번째 컬럼
                    GridItem(.flexible()), // 두 번째 컬럼
                    GridItem(.flexible())  // 세 번째 컬럼
                ]
                LazyVGrid(columns: columns, spacing:20) { // 3개의 열, 각 열 간 간격 10
                    ForEach(finishedHabits ?? [], id: \.self) { habit in
                        //                ForEach(habits, id: \.self) {habit in
                        VStack {
                            if let imageData = habit.sortedDaily.first?.diary?.first?.image{
                                let uiImage = loadImage(from: imageData)
                                if let convertedImage = uiImage{
                                    NavigationLink(destination:FinishedHabitView(habitID: habit.id)){
                                        ZStack{
                                            Rectangle()
                                                .frame(width:90, height:90)
                                                .cornerRadius(15)
                                                .foregroundColor(Color(.white))
                                            
                                            Image(uiImage: convertedImage)
                                                .resizable()
                                                .frame(width:80, height: 80)
                                                .cornerRadius(10)
                                                .scaledToFit()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            else{
                Text("아직 완료한 습관이 없어요!")
                    .font(.system(size:14))
                    .foregroundColor(Color("StrongBlue-font"))
                    .padding(.top,200)
            }
        }
        .frame(width:350, height:450)
        .padding(.top,10)
    }
    func loadImage(from imageData: Data?) -> UIImage? {
        guard let imageData = imageData else { return nil }
        return UIImage(data: imageData)
    }
}

#Preview {
    GalleryView()
}
