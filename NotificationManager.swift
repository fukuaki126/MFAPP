import UserNotifications
import Foundation

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}

    // 通知の許可をリクエスト
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("通知の許可エラー: \(error)")
            }
        }
    }

    // 習慣タスク（habit）の通知スケジュール
    func scheduleHabitTaskNotification(task: Task) {
        guard let alertDays = task.alertDays,
              let lastCompletedDate = task.lastCompletedDate,
              let notificationTime = task.notificationTime else {
            return
        }

        let daysSinceLastCompletion = Calendar.current.dateComponents([.day], from: lastCompletedDate, to: Date()).day ?? 0

        if daysSinceLastCompletion >= alertDays {
            // 毎日通知
            scheduleDailyNotification(task: task)
        } else {
            // 初回通知日 = 最終実行日 + 警告日数
            var notifyDate = Calendar.current.date(byAdding: .day, value: alertDays, to: lastCompletedDate)!

            // 通知時間を反映
            let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
            notifyDate = Calendar.current.date(bySettingHour: timeComponents.hour ?? 9,
                                               minute: timeComponents.minute ?? 0,
                                               second: 0,
                                               of: notifyDate) ?? notifyDate

            scheduleOneTimeNotification(task: task, date: notifyDate)
        }
    }

    // 🔔 リマインダータスク（reminder）の通知スケジュール
    func scheduleReminderTaskNotification(task: Task) {
        guard let dueDate = task.dueDate else { return }

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: task.id.uuidString,
            content: makeNotificationContent(task),
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    // 毎日通知（habit用）
    private func scheduleDailyNotification(task: Task) {
        guard let notificationTime = task.notificationTime else { return }

        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
        dateComponents.second = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: makeNotificationContent(task), trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }

    // 1回だけの通知（habitの初回や reminderで使用）
    private func scheduleOneTimeNotification(task: Task, date: Date) {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: makeNotificationContent(task), trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }

    // 通知の内容
    private func makeNotificationContent(_ task: Task) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = task.taskType == .habit ? "習慣タスクのリマインダー" : "リマインダー"
        content.body = "\(task.title) を実行する時間です！"
        content.sound = .default
        return content
    }

    // 通知のキャンセル
    func cancelNotification(task: Task) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])
    }
}
