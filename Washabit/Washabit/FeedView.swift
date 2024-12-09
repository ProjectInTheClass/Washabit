// 일별 기록 피드 화면

import SwiftUI

struct FeedView: View {
    @State private var title = "이불 정리하기"
    var body: some View {
        ZStack{
            Color("MainColor")
            VStack{
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
                HStack{
                    Text("<\(title)> 피드")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color("StrongGray-font"))
                        .padding(.leading,20)
                    Spacer()
                    Text("모아보기>")
                        .font(.system(size:14))
                        .underline()
                        .foregroundColor(Color("StrongGray-font"))
                        .padding(.trailing,20)
                }
                .padding(.top, 15)
                
                
                ExpandableCalendar()
                    .frame(width:375)
                    .padding(.top,15)
                
                ScrollFeedView()
                
            }
            .padding(30)
            .padding(.top, 60)
        }
        .ignoresSafeArea()
    }
}

struct ScrollFeedView: View{
    var body: some View{
        ScrollView(){
//            LazyVStack(pinnedViews: .sectionHeaders){
//                Section(header:WeeklyCalendarView()){
//                    ForEach(0..<5){ i in
//                        FeedContentView()
//                    }
//                }
//                .background(Color("MainColor"))
//            }
            ForEach(0..<5){ i in
                FeedContentView()
            }
        }
    }
}

struct FeedContentView: View{
    struct Daily{
        var count:Int = 0
        var image:String
        var descr:String
        init(value:Int, imageName:String, description:String)
        {
            self.count = value
            self.image = imageName
            self.descr = description
        }
    }
    
    let daily1 = Daily.init(value: 4, imageName: "", description: "일어나자마자 했어야되는데 그냥 씻으러 가버려서 못했다. 바쁜 아침 대신 여유로운 아침을 가질 수 있길..")
    
    var body:some View{
        ZStack{
            Color(.white)
            VStack{
                Image("sample_image")
                Spacer()
                Text(daily1.descr)
                    .font(.system(size: 15))
            }
            .padding(10)
        }
        .frame(width:345)
        .cornerRadius(15)
        .padding(.bottom,15)
    }
}

#Preview {
    FeedView()
}
 

