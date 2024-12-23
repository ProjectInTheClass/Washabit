// 일별 기록 피드 화면

import SwiftUI
import SwiftData
import Foundation
import PhotosUI

struct FeedView: View {
    @Environment(\.presentationMode) var presentationMode
    let habitID:UUID
    
    @Query private var habits:[HabitData]
    
    private var habit: HabitData? {
        habits.first(where: { $0.id == habitID })
    }
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var isPhotoPickerPresented: Bool = false
    @State var selectedItem:PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var selectedDate:Date = Date()
    
    init(initialDate: Date, habitID:UUID) {
        self._selectedDate = State(initialValue: initialDate)
        self.habitID = habitID
    }
    
    @State private var isNavigating = false
    
//    private var habits:[HabitData] = HabitData.sampleData
//    private var habit :HabitData? {
//        habits.first(where: {$0.title == "운동하기"})
//    }
    @State private var content:String = ""
    
    var body: some View {
        ZStack{
            Color("MainColor")
            VStack{
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
                        .padding(.leading,20)
                        Spacer()
                    }
                }
                HStack{
                    if let title = habit?.title {
                        Text("<\(title)> 피드")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color("StrongGray-font"))
                            .padding(.leading,20)
                    }
                    Spacer()
                    Text("모아보기>")
                        .font(.system(size:14))
                        .underline()
                        .foregroundColor(Color("StrongGray-font"))
                        .padding(.trailing,20)
                }
                .padding(.top, 15)
                
                ExpandableCalendar(selectedDate: $selectedDate)
                    .frame(width:375)
                    .padding(.top,10)
                HStack{
                    TextField("오늘의 습관 한줄평", text:$content)
                        .padding()
                        .frame(width:280, height:55)
                        .background(Color(.white))
                        .foregroundColor(Color("StrongGray-font"))
                        .cornerRadius(10)
                        .padding(.top,-10)
                        .padding(.bottom,10)
                        .overlay(
                            HStack{
                                Spacer()
                                
                                PhotosPicker(
                                    selection: $selectedItem,
                                    matching: .images
                                ) {
                                    if let selectedImage = selectedImage {
                                        // 선택된 이미지 미리보기
                                        Image(uiImage: selectedImage)
                                            .resizable()
                                            .frame(width:40, height: 40)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            .padding(.trailing,10)
                                            .padding(.bottom,20)
                                    }
                                    else{
                                        Image("Icons/gallery")
                                            .resizable()
                                            .frame(width:30, height:30)
                                            .padding(.trailing,10)
                                            .padding(.bottom,20)
                                    }
                                }
                                .onChange(of: selectedItem) { newItem in
                                    // 사용자가 이미지를 선택하면 실행
                                    Task {
                                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                                           let uiImage = UIImage(data: data) {
                                            selectedImage = uiImage // 화면에 표시
                                        }
                                    }
                                }
                            }
                        )
                                
                    
                    Button{
                        if let image = selectedImage {
                            if let imageData = image.jpegData(compressionQuality: 0.8){
                                HabitManager.addNewDiary(habitID, habit?.goalCount ?? 0, content, imageData, Date(), to: modelContext)
                                selectedImage = nil
                                content = ""
                            }
                            else {return}
                        }
                        else{
                            return
                        }
                    }label: {
                    RoundedRectangle(cornerRadius: 8)
                        .frame(width:40, height:40)
                        .foregroundColor(Color("LightBlue").opacity(0.3))
                        .padding(.leading,10)
                        .padding(.bottom,20)
                        .overlay(
                            Image("Icons/checkmark")
                                .padding(.leading,10)
                                .padding(.bottom,20)
                        )
                    }
                }
                if let habit = habit {
                    ScrollFeedView(habit, selectedDate)
                }
                
            }
            .padding(30)
            .padding(.top, 80)
        }
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
        
    }
    
    func ScrollFeedView(_ habitData:HabitData, _ date:Date) -> some View{
        ScrollView(){
            let calendar = Calendar.current
                    
            // habitData의 daily에서 날짜가 같은 항목만 필터링
            let dailyData = habitData.sortedDaily.filter {
                calendar.isDate($0.date, equalTo: date, toGranularity: .day)
            }
            
            if let dailyData = dailyData.first {
                ForEach(dailyData.sortedDiary){ diaryData in
                    FeedContentView(diaryData)
                }
            }
        }
    }
    
    func FeedContentView(_ diaryData: Diary) ->some View{
        ZStack{
            Color(.white)
            VStack{
                HStack{
                    let calendar = Calendar.current
                    let month = calendar.component(.month, from: diaryData.date)
                    let day = calendar.component(.day, from: diaryData.date)
                    let hour = calendar.component(.hour, from: diaryData.date)
                    let minute = calendar.component(.minute, from: diaryData.date)
                    Text("✏️ \(month)-\(day) \(hour)시 \(minute)분")
                        .font(.system(size: 15))
                        .foregroundColor(Color("LightGray"))
                        .padding(.leading,10)
                    Spacer()
                    Image("Icons/more")
                        .padding(.trailing,20)
                }
                if let uiImage = loadImage(from: diaryData.image) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width:345, height:345)
                        .clipped()
                }
                
                HStack{
                    Text(diaryData.content)
                        .font(.system(size: 15))
                        .padding(.top, 5)
                        .padding(.leading, 10)
                    Spacer()
                }
            }
            .padding([.top,.bottom], 15)
        }
        .frame(width:345)
        .cornerRadius(15)
        .padding(.bottom,15)
    }
    
    func loadImage(from imageData: Data?) -> UIImage? {
        guard let imageData = imageData else { return nil }
        return UIImage(data: imageData)
    }
}


//#Preview {
//    FeedView()
//}
// 

