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

@Test func brandHexIsTheRequestedPeriwinkle() {
	let rgb = Color.rgb(hex: AppColor.brandHex)
	// The brand color as picked, in normalized components: R 0.779, G 0.784, B 0.896.
	#expect(((rgb?.r ?? 0) - 0.779).magnitude < 0.005)
	#expect(((rgb?.g ?? 0) - 0.784).magnitude < 0.005)
	#expect(((rgb?.b ?? 0) - 0.896).magnitude < 0.005)
}
