import SwiftUI

/// The signature treatment: telemetry (coordinates, timestamps, file sizes) rendered in a monospaced,
/// tabular face and the telemetry color, so data reads like instrument output across the app.
public struct TelemetryText: View {
    private let text: String
    public init(_ text: String) { self.text = text }

    public var body: some View {
        Text(text)
            .font(AppFont.mono)
            .monospacedDigit()
            .foregroundStyle(AppColor.telemetry)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: AppSpacing.sm) {
        TelemetryText(TelemetryFormatter.coordinate(lat: 45.708865, lon: 9.696590))
        TelemetryText(TelemetryFormatter.bytes(167_772_160))
        TelemetryText("11:57:04")
    }
    .padding()
    .background(AppColor.background)
}
