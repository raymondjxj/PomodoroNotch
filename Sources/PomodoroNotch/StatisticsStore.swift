import Foundation

struct DayStats: Codable {
    let date: String // "2026-04-30"
    var completedPomodoros: Int
    var totalFocusSeconds: Int
}

@MainActor
final class StatisticsStore: ObservableObject {
    @Published var todayStats: DayStats
    @Published var weekStats: [DayStats] = []

    private let fileURL: URL
    private var allStats: [DayStats] = []

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let folder = appSupport.appendingPathComponent("PomodoroNotch")
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        fileURL = folder.appendingPathComponent("stats.json")

        todayStats = DayStats(date: Self.todayString(), completedPomodoros: 0, totalFocusSeconds: 0)
        load()
    }

    func recordPomodoro(seconds: Int) {
        let today = Self.todayString()
        if todayStats.date != today {
            todayStats = DayStats(date: today, completedPomodoros: 0, totalFocusSeconds: 0)
        }
        todayStats.completedPomodoros += 1
        todayStats.totalFocusSeconds += seconds
        save()
    }

    // MARK: - Private

    private static func todayString() -> String {
        dateFormatter.string(from: Date())
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL),
           let stats = try? JSONDecoder().decode([DayStats].self, from: data) {
            allStats = stats
        }
        if let existing = allStats.first(where: { $0.date == todayStats.date }) {
            todayStats = existing
        }
        updateWeek()
    }

    private func save() {
        if let idx = allStats.firstIndex(where: { $0.date == todayStats.date }) {
            allStats[idx] = todayStats
        } else {
            allStats.append(todayStats)
        }
        allStats = Array(allStats.suffix(90))

        if let data = try? JSONEncoder().encode(allStats) {
            try? data.write(to: fileURL)
        }
        updateWeek()
    }

    private func updateWeek() {
        let today = Self.todayString()
        guard let todayDate = Self.dateFormatter.date(from: today) else { return }

        let weekDays = (0..<7).compactMap { dayOffset -> String? in
            guard let date = Calendar.current.date(byAdding: .day, value: -dayOffset, to: todayDate) else { return nil }
            return Self.dateFormatter.string(from: date)
        }

        weekStats = weekDays.compactMap { dateStr in
            if dateStr == today { return todayStats }
            return allStats.first(where: { $0.date == dateStr }) ?? DayStats(date: dateStr, completedPomodoros: 0, totalFocusSeconds: 0)
        }.sorted { $0.date < $1.date }
    }
}
