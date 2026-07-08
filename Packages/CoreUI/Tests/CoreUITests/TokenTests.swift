import SwiftUI
import Testing
@testable import CoreUI

@Test func spacingScaleIsMonotonic() {
    let scale = [
        AppSpacing.xxs, AppSpacing.xs, AppSpacing.sm, AppSpacing.md,
        AppSpacing.lg, AppSpacing.xl, AppSpacing.xxl, AppSpacing.xxxl
    ]
    #expect(scale == scale.sorted())
    #expect(AppSpacing.md == 12)
}

@Test func radiusScaleIsDefined() {
    #expect(AppRadius.sm < AppRadius.md)
    #expect(AppRadius.md < AppRadius.lg)
}

@Test func gridCellSizeTokenIsPositive() {
    #expect(AppSize.gridCellMin > 0)
}
