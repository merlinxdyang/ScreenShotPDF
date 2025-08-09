//
//  ScreenshotToolApp.swift
//  ScreenshotTool
//
//  Created by Merlin Yang on 8/3/25.
//
import SwiftUI

@main
struct ScreenshotToolApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
        .windowToolbarStyle(.unified)
        .commands {
            // 移除默认的 "New" 菜单项
            CommandGroup(replacing: .newItem) {}
        }
    }
}
