//
// Example app that hosts the Flag Toggle plugin.
//
// Shows how to register the plugin with an injected flag and config.
// Here the flag is a simple in-memory override; a real app would read/write
// its own feature flag or A/B value.
//

import NectoSDK
import SwiftUI
import NectoFlagTogglePlugin

// 1. Store managing user states and variant toggles for real-time verification
class DemoFlagStore: ObservableObject {
    @Published var override: Bool? = nil
    var isOn: Bool { override ?? false }
    
    @MainActor static let shared = DemoFlagStore()
}

@main
struct ExampleApp: App {
    init() {
        // Register the Necto plugin to switch user states or variants on the fly
        NectoSDK.register(NectoFlagTogglePlugin(
            config: .init(
                title: "User State / Variant Toggle",
                onLabel: "Variant B (Nitro / VIP)",
                offLabel: "Control (Free User)",
                note: "Switch user states or test variants instantly from the sidebar."
            ),
            read: {
                // Safely read state from the main thread
                if Thread.isMainThread {
                    return DemoFlagStore.shared.isOn
                } else {
                    return DispatchQueue.main.sync {
                        DemoFlagStore.shared.isOn
                    }
                }
            },
            write: { value in
                // Safely write state back on the main thread
                DispatchQueue.main.async {
                    DemoFlagStore.shared.override = value
                }
            }
        ))
        NectoSDK.start()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @ObservedObject private var flagStore = DemoFlagStore.shared

    var body: some View {
        // Discord Deep Indigo canvas background (#0a0d3a)
        ZStack {
            Color(hex: "0a0d3a")
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Top status badge indicating the active variant or user tier
                HStack(spacing: 8) {
                    Image(systemName: flagStore.isOn ? "sparkles" : "person.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "ffffff"))
                    Text(flagStore.isOn ? "EXPERIMENT: VARIANT B (VIP)" : "EXPERIMENT: CONTROL (FREE)")
                        .font(.system(size: 12, weight: .bold))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(flagStore.isOn ? Color(hex: "ec48bd") : Color(hex: "5865f2")) // Magenta for ON, Blurple for OFF
                .cornerRadius(16)

                Spacer()

                // Central card area for live verification of UI changes
                VStack(alignment: .center, spacing: 16) {
                    if flagStore.isOn {
                        // [ON / Variant B] Premium user or experimental Variant B view
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 56))
                            .foregroundColor(Color(hex: "35ed7e")) // Electric Green
                        
                        Text("VARIANT B: VIP EXPERIENCE")
                            .font(.system(size: 22, weight: .heavy))
                            .foregroundColor(Color(hex: "ffffff"))
                            .multilineTextAlignment(.center)
                        
                        Text("You are viewing the experimental feature set with custom themes, high-res audio perks, and priority access.")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(Color(hex: "ffffff"))
                            .opacity(0.8)
                            .multilineTextAlignment(.center)
                    } else {
                        // [OFF / Control] Default standard user or Control view
                        Image(systemName: "person.crop.circle.badge.exclamationmark")
                            .font(.system(size: 56))
                            .foregroundColor(Color(hex: "5865f2")) // Blurple accent
                        
                        Text("CONTROL: STANDARD VIEW")
                            .font(.system(size: 22, weight: .heavy))
                            .foregroundColor(Color(hex: "ffffff"))
                            .multilineTextAlignment(.center)
                        
                        Text("You are currently seeing the default standard experience. Toggle the plugin in your Mac sidebar to test Variant B instantly.")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(Color(hex: "ffffff"))
                            .opacity(0.8)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            // Action handler for simulated user interactions
                        }) {
                            Text("Simulate Action")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(hex: "000000"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(hex: "35ed7e"))
                                .cornerRadius(12)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(24)
                .background(Color(hex: "1e2353")) // Raised Indigo surface
                .cornerRadius(40)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color(hex: "23272a"), lineWidth: 1)
                )
                .padding(.horizontal, 16)
                .transition(.scale.combined(with: .opacity))

                Spacer()

                // Bottom instruction footer text
                Text("🛠️ Use the Necto sidebar to switch user states and verify layouts on the fly.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "ffffff"))
                    .opacity(0.6)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
        .animation(.easeInOut(duration: 0.25), value: flagStore.isOn)
    }
}

// Utility extension to easily convert hex color codes into SwiftUI Color instances
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
