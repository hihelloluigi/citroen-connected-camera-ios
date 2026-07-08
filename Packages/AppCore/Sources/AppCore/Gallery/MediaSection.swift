import Foundation
import VIRBKit

/// A day's worth of media, titled for display ("Today", "Yesterday", a date, or "Undated").
public struct MediaSection: Equatable, Identifiable, Sendable {
	public let id: String
	public let title: String
	public let items: [MediaItem]

	public init(id: String, title: String, items: [MediaItem]) {
		self.id = id
		self.title = title
		self.items = items
	}
}

/// Groups media into day sections, newest day first and newest item first within a day. Items the
/// camera didn't date collect into a trailing "Undated" section. Pure and deterministic given
/// `calendar`/`now`, so the view can group without the view model needing a clock.
public enum MediaGrouping {
	public static func sections(from items: [MediaItem], calendar: Calendar = .current,
								now: Date = Date()) -> [MediaSection] {
		let dated = items.compactMap { item in item.date.map { (item, $0) } }
		let undated = items.filter { $0.date == nil }

		let byDay = Dictionary(grouping: dated) { calendar.startOfDay(for: $0.1) }
		var sections = byDay
			.sorted { $0.key > $1.key }
			.map { day, pairs -> MediaSection in
				let sortedItems = pairs.sorted { $0.1 > $1.1 }.map(\.0)
				return MediaSection(id: ISO8601DateFormatter().string(from: day),
									title: title(for: day, calendar: calendar, now: now),
									items: sortedItems)
			}
		if !undated.isEmpty {
			sections.append(MediaSection(id: "undated", title: "Undated", items: undated))
		}
		return sections
	}

	private static func title(for day: Date, calendar: Calendar, now: Date) -> String {
		if calendar.isDate(day, inSameDayAs: now) { return "Today" }
		if let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: now)),
		   calendar.isDate(day, inSameDayAs: yesterday) { return "Yesterday" }
		let formatter = DateFormatter()
		formatter.calendar = calendar
		formatter.dateStyle = .medium
		formatter.timeStyle = .none
		return formatter.string(from: day)
	}
}
