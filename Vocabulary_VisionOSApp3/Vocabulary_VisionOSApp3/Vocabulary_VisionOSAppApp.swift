//
//  Vocabulary_VisionOSAppApp.swift
//  Vocabulary_VisionOSApp
//
//  Created by Moritz Mueller on 13.01.25.
//

import SwiftUI

@main
struct Vocabulary_VisionOSAppApp2: App {
    var body: some Scene {
        
        ImmersiveSpace(id: "myImmersiveScene") {
            // Hier rufen wir unsere (bisherige) ContentView auf
            ContentView()
        }
    }
}
