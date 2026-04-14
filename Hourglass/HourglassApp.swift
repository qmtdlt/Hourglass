//
//  HourglassApp.swift
//  Hourglass
//
//  Created by 张浩 on 2026/3/30.
//

import SwiftUI
import UIKit

@main
struct HourglassApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    UIApplication.shared.isIdleTimerDisabled = true
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            UIApplication.shared.isIdleTimerDisabled = (newPhase == .active)
        }
    }
}
