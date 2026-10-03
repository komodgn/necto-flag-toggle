//
// NectoFlagTogglePlugin
//
// A generic necto device plugin that remotely toggles an app's Bool flag
// from the necto sidebar. Display strings (config) and value read/write are
// injected, so it is not tied to any specific app.
//
// Example:
//   NectoSDK.register(NectoFlagTogglePlugin(
//       config: .init(title: "Dark Mode", onLabel: "ON", offLabel: "OFF"),
//       read:  { AppFlags.darkMode },
//       write: { AppFlags.darkModeOverride = $0 }   // nil = clear override
//   ))
//


import NectoSDK
import NectoModel 

public struct NectoFlagTogglePlugin: NectoPlugin {
    public let id = "com.example.necto-flag-toggle"

    public struct Config: Sendable {
        public let title: String
        public let onLabel: String
        public let offLabel: String
        public let note: String

        public init(
            title: String = "Flag Toggle",
            onLabel: String = "ON",
            offLabel: String = "OFF",
            note: String = ""
        ) {
            self.title = title
            self.onLabel = onLabel
            self.offLabel = offLabel
            self.note = note
        }
    }

    private let config: Config
    private let read: @Sendable () -> Bool
    private let write: @Sendable (Bool?) -> Void

    public init(
        config: Config = .init(),
        read: @escaping @Sendable () -> Bool,
        write: @escaping @Sendable (Bool?) -> Void
    ) {
        self.config = config
        self.read = read
        self.write = write
    }

    public var panel: NectoPluginPanel? {
        NectoPluginPanel(bundle: .module)
    }

    public func register(_ necto: NectoRegistrar) {
        let read = self.read
        let write = self.write
        let config = self.config

        let stateSchema: NectoJSONValue = .object([
            "type": .string("object"),
            "properties": .object([
                "on": .object([
                    "type": .string("boolean")
                ])
            ]),
            "required": .array([.string("on")]),
            "additionalProperties": .bool(false),
        ])
        
        let state: @Sendable () -> NectoJSONValue = { .object(["on": .bool(read())]) }

                necto.handle("flag.get", outputSchema: stateSchema) { _ in state() }
                necto.handle("flag.toggle", outputSchema: stateSchema) { _ in write(!read()); return state() }
                necto.handle("flag.enable", outputSchema: stateSchema) { _ in write(true); return state() }
                necto.handle("flag.disable", outputSchema: stateSchema) { _ in write(false); return state() }
                necto.handle("flag.reset", outputSchema: stateSchema) { _ in write(nil); return state() }
        
        necto.handle(
            "flag.config",
            outputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "title": .object(["type": .string("string")]),
                    "onLabel": .object(["type": .string("string")]),
                    "offLabel": .object(["type": .string("string")]),
                    "note": .object(["type": .string("string")]),
                ]),
                "required": .array([
                    .string("title"),
                    .string("onLabel"),
                    .string("offLabel"),
                    .string("note"),
                ]),
                "additionalProperties": .bool(false),
            ])
        ) { _ in
            .object([
                "title": .string(config.title),
                "onLabel": .string(config.onLabel),
                "offLabel": .string(config.offLabel),
                "note": .string(config.note),
            ])
        }
    }
}
