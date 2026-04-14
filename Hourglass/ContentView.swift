//
//  ContentView.swift
//  Hourglass
//
//  Created by 张浩 on 2026/3/30.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var timerVM = TimerViewModel()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.08, blue: 0.12),
                    Color(red: 0.12, green: 0.10, blue: 0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            MainTimerView(vm: timerVM)
        }
    }
}

#Preview {
    ContentView()
}
