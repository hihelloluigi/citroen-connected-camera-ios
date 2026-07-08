import UIKit

/// Opens the app's page in the system Settings, where the user can change a permission the app can't
/// re-prompt for (Local Network can never be re-prompted; Location/Photos can't once denied).
enum AppSettings {
    @MainActor
    static func open() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
