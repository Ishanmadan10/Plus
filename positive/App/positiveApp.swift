//
//  positiveApp.swift
//  positive
//
//  Created by ishan madan  on 16/05/26.
//
//
//import SwiftUI
//
//@main
//struct positiveApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
//import SwiftUI
//
//@main
//struct PositiveApp: App {
//    var body: some Scene {
//        WindowGroup {
//            HomeView()
//                .preferredColorScheme(.light)
//        }
//    }
//}
import SwiftUI

@main
struct PositiveApp: App {
    init() {
          NotificationManager.shared.requestPermission()  // ✅ add this
      }
    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(.light)
        }
    }
}
