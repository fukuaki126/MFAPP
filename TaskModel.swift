import Foundation

enum TaskType: String, CaseIterable, Codable {
    case habit = "習慣"
    case reminder = "リマインダー"
}

struct Task: Identifiable, Codable {
    var id = UUID()
    var title: String
    var taskType: TaskType
    var lastCompletedDate: Date?
    var dueDate: Date?
    var alertDays: Int?
    var notificationTime: Date? // 🔔 通知時間を追加
    var isCompleted: Bool
}
