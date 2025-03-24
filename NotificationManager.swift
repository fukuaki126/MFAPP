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

    // 通知をスケジュール
    func scheduleHabitTaskNotification(task: Task) {
        guard let alertDays = task.alertDays, let lastCompletedDate = task.lastCompletedDate, let notificationTime = task.notificationTime else {
            return
        }

        let daysSinceLastCompletion = Calendar.current.dateComponents([.day], from: lastCompletedDate, to: Date()).day ?? 0

        // すでに警告日数を超えているなら、毎日通知
        if daysSinceLastCompletion >= alertDays {
            scheduleDailyNotification(task: task)
        } else {
            // 初回警告通知をセット
            let notifyDate = Calendar.current.date(byAdding: .day, value: alertDays, to: lastCompletedDate)!
            scheduleOneTimeNotification(task: task, date: notifyDate)
        }
    }

    // 毎日通知
    private func scheduleDailyNotification(task: Task) {
        guard let notificationTime = task.notificationTime else { return }

        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
        dateComponents.second = 0 // 秒単位は不要

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: makeNotificationContent(task), trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }

    // 1回だけの通知
    private func scheduleOneTimeNotification(task: Task, date: Date) {
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date), repeats: false)
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: makeNotificationContent(task), trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }

    // 通知内容
    private func makeNotificationContent(_ task: Task) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "習慣タスクのリマインダー"
        content.body = "\(task.title) を実行する時間です！"
        content.sound = .default
        return content
    }

    // 通知をキャンセル（タスク完了時など）
    func cancelNotification(task: Task) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])
    }
}
