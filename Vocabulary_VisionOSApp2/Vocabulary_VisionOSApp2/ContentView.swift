import SwiftUI
import RealityKit
import ARKit

struct ContentView: View {
    @State private var isFrontVisible: Bool = true // Steht der Nutzer vor dem Fenster?
    @State private var userDistanceZ: Float = 0.0 // Entfernung des Nutzers auf der Z-Achse
    private let windowPositionZ: Float = -1.6 // Z-Position des Fensters
    @State private var userViewHeight: Float = 1.6
    
    @State var session = ARKitSession()
    @State var worldTrackingProvider = WorldTrackingProvider()
    
    @State private var gameplay = false // Steuerung zwischen GameView und MenueView
    @StateObject private var loader = ReadVocabularyJson()
    @StateObject private var settings = Settings()
    
    var body: some View {
        RealityView { content, attachments in
            // Anker und Fenster-Setup
            let anchor = AnchorEntity(world: [0, 0, 0])
            content.add(anchor)
            
            // Hinzufügen der Views als Attachment
            if let zStackAttachment = attachments.entity(for: "ZStackAttachment") {
                zStackAttachment.position = [0, 1.6, windowPositionZ]
                anchor.addChild(zStackAttachment)
            }
                
            if let zStackAttachment2 = attachments.entity(for: "ZStackAttachment2") {
                zStackAttachment2.position = [0, 1.6, windowPositionZ - 1.6]
                anchor.addChild(zStackAttachment2)
            }
        } attachments: {
            // SwiftUI-Inhalt je nach Sichtbarkeit (vorne/hinten)
                Attachment(id: "ZStackAttachment") {
                        if !gameplay {
                            MenueView(gameplay: $gameplay)
                                .environmentObject(settings)
                        }
                        else if(isFrontVisible) {
                            ListView(gameplay: $gameplay, loader: loader)
                                .environmentObject(settings)
                        }
            }
            
            
            Attachment(id: "ZStackAttachment2") {
                if(!isFrontVisible && gameplay){
                    GameView(gameplay: $gameplay, loader: loader, settings: settings)
                    .environmentObject(settings)
                }
            }
        }
        .task {
            do {
                try await session.run([worldTrackingProvider])
                
                // Starte die Schleife zur kontinuierlichen Aktualisierung
                while true {
                    if worldTrackingProvider.state == .running,
                       let deviceAnchor = worldTrackingProvider.queryDeviceAnchor(atTimestamp: CACurrentMediaTime()) {
                        let cameraTransform = deviceAnchor.originFromAnchorTransform
                        let cameraPosition = cameraTransform.columns.3
                        
                        // Aktualisiere die Entfernung auf der Z-Achse
                        DispatchQueue.main.async {
                            userDistanceZ = cameraPosition.z - windowPositionZ
                            userViewHeight = cameraPosition.y
                        }
                        
                        if(userDistanceZ > 0){
                            isFrontVisible = true
                        } else {
                            isFrontVisible = false
                        }
                    }
                    try await Task.sleep(nanoseconds: 100_000_000) // 100ms warten
                }
            } catch {
                print("Error: \(error)")
            }
        }
    }
}

