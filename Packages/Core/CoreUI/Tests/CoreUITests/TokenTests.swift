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

@Test func brandHexesMatchTheAppIcon() {
	// Sampled from AppIcon's 1024pt artwork: the field it is drawn on, and the road.
	let field = Color.rgb(hex: AppColor.brandHex)
	#expect(((field?.r ?? 0) - 0.114).magnitude < 0.005)
	#expect(((field?.g ?? 0) - 0.655).magnitude < 0.005)
	#expect(((field?.b ?? 0) - 0.608).magnitude < 0.005)

	let road = Color.rgb(hex: AppColor.brandDeepHex)
	#expect(((road?.r ?? 0) - 0.012).magnitude < 0.005)
	#expect(((road?.g ?? 0) - 0.431).magnitude < 0.005)
	#expect(((road?.b ?? 0) - 0.427).magnitude < 0.005)
}
