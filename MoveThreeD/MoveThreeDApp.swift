//
//  MoveThreeDApp.swift
//  MoveThreeD
//
//  Created by Subash Shrestha on 07.08.24.
//

import SwiftUI

@main
struct MoveThreeDApp: App {
    var body: some Scene {
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }.immersionStyle(selection: .constant(.full), in: .full)
    }
}
