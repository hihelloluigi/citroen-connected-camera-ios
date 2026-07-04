import SwiftUI

/// A minimal button style: no system chrome, just a press dim so every CoreUI button gives touch
/// feedback. Replaces `.plain`, which strips SwiftUI's default highlight without adding one back.
public struct PressableButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label.opacity(configuration.isPressed ? AppOpacity.pressed : 1)
    }
}
