import CoreGraphics

/// Fixed component dimensions that aren't spacing, radius, or icon sizes — e.g. the minimum width of a
/// media grid cell. Kept as tokens so layout sizing stays consistent and never hard-coded at call sites.
public enum AppSize {
    /// Minimum width of a gallery grid cell; the grid packs as many columns as fit above this.
    public static let gridCellMin: CGFloat = 100
}
