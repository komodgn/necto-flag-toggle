//
// Copyright (c) 2026 Viva Republica, Inc.
//

import NectoSDK
import SwiftUI
import NectoFlagTogglePlugin

@main
struct ExampleApp: App {
    init() {
        NectoSDK.register(NectoFlagTogglePlugin())
        NectoSDK.start()
    }

    var body: some Scene {
        WindowGroup {
            VStack(spacing: 12) {
                Image(systemName: "cable.connector")
                    .font(.largeTitle)
                Text("Necto Flag Toggle")
                    .font(.headline)
                Text("Run Necto on your Mac to open the plugin panel.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
    }
}
