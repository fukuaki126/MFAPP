import Foundation

enum TaskType: String, Codable, CaseIterable {
    case habit = "習慣タスク"
    case reminder = "リマインダー"
}

struct Task: Codable, Identifiable {
    var id = UUID()
    var title: String
    var taskType: TaskType
    var lastCompletedDate: Date?
    var dueDate: Date?
    var isCompleted: Bool
}
