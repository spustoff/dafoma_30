//
//  NeonFiscalApp.swift
//  NeonFiscal Kangwon
//
//  Created by Вячеслав on 8/26/25.
//

import SwiftUI

@main
struct NeonFiscalApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(DataService.shared)
        }
    }
}
