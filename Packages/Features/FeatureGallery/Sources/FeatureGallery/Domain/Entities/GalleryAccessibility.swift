//
//  GalleryAccessibility.swift
//  FeatureGallery
//

import CoreLocalization

public enum GalleryAccessibility {
	public static func label(for item: MediaEntity) -> String {
		let kind = item.kind == .video ? GalleryStrings.video : GalleryStrings.photo
		return item.gpsLatitude != nil ? GalleryStrings.geotagged(kind: kind) : kind
	}
}
