//
//  ViewComponents.swift
//  Washabit
//
//  Created by 강현중 on 11/24/24.
//

import SwiftUI

/// 물 채우기 뷰 (진행률 표시)
struct WaterFillView: View {
    @Binding var progress: CGFloat
    @State private var waveOffset: CGFloat = 0.0
    @State private var timer: Timer?

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.gray.opacity(0.1))
                .frame(width: 213, height: 213)
        
            WaterShape(level: progress, waveOffset: waveOffset)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.blue]),
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .frame(width: 200, height: 200)
                .clipShape(Circle())
                .animation(.easeInOut(duration: 0.8), value: progress)
            
            Circle()
                .strokeBorder(Color.blue.opacity(0.3), lineWidth: 10)
                .frame(width: 215, height: 215)
        }
        .onAppear {
            startWaveAnimation()
        }
        .onDisappear {
            stopWaveAnimation()
        }
    }
    
    private func startWaveAnimation() {
        stopWaveAnimation()
        timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
            waveOffset += 0.07
        }
    }
    
    private func stopWaveAnimation() {
        timer?.invalidate()
        timer = nil
    }
}

/// 물결 애니메이션을 위한 Shape
struct WaterShape: Shape {
    var level: CGFloat
    var waveOffset: CGFloat

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(level, waveOffset) }
        set {
            level = newValue.first
            waveOffset = newValue.second
        }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let waterHeight = rect.height * (1.0 - level)
        
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: waterHeight))
        
        for x in stride(from: 0.0, to: Double(rect.width), by: 1.0) {
            let relativeX = CGFloat(x) / rect.width
            let yOffset = sin(relativeX * .pi * 2 + waveOffset) * 10
            path.addLine(to: CGPoint(x: CGFloat(x), y: waterHeight + yOffset))
        }
        
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()
        
        return path
    }
}

/// 카운트 조정 팝업 뷰
struct CountAdjustPopoverView: View {
    var daily: Daily
    var onClose: () -> Void
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Button(action: {
                    if daily.count > 0 {
                        daily.count -= 1
                        saveContext()
                    }
                }) {
                    Text("-")
                        .font(.title3)
                        .frame(width: 30, height: 30)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                Text("\(daily.count)")
                    .font(.caption)
                Button(action: {
                    daily.count += 1
                    saveContext()
                }) {
                    Text("+")
                        .font(.title3)
                        .frame(width: 30, height: 30)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
            }
        }
        .padding(8)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(radius: 4)
        .frame(width: 120)
    }
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("데이터 저장 실패: \(error)")
        }
    }
}


