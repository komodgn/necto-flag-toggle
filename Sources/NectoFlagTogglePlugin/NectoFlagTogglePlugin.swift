//
// Copyright (c) 2026 Viva Republica, Inc.
//

import NectoSDK

public struct NectoFlagTogglePlugin: NectoPlugin {
    public let id = "com.example.necto-flag-toggle"

    public init() {}

    public var panel: NectoPluginPanel? {
        NectoPluginPanel(bundle: .module)
    }

    public func register(_ necto: NectoRegistrar) {
        necto.handle(
            "message.get",
            outputSchema: [
                "type": "object",
                "properties": [
                    "message": ["type": "string"],
                ],
                "required": ["message"],
                "additionalProperties": false,
            ]
        ) { _ in
            ["message": .string("Hello from Necto Flag Toggle")]
        }
    }
}
