import SwiftUI

struct EditHabitTaskView: View {
    @Binding var task: Task
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode

    // 一時的な @State 変数を使用
    @State private var lastCompletedDate: Date
    @State private var notificationTime: Date
    @State private var alertDays: Int

    init(task: Binding<Task>) {
        self._task = task
        // task の値を初期化する
        _lastCompletedDate = State(initialValue: task.wrappedValue.lastCompletedDate ?? Date())
        _notificationTime = State(initialValue: task.wrappedValue.notificationTime ?? Date())
        _alertDays = State(initialValue: task.wrappedValue.alertDays ?? 0)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("タスク詳細")) {
                    TextField("タスク名", text: $task.title)
                    
                    // 最終実行日
                    DatePicker("最終実行日", selection: $lastCompletedDate, displayedComponents: [.date])
                    
                    // 警告日数
                    HStack {
                        Text("警告日数")
                        Spacer()
                        TextField("0", text: Binding(
                            get: { String(alertDays) },
                            set: { newValue in
                                //  数値変換が成功した場合のみ更新
                                if let intValue = Int(newValue) {
                                    alertDays = intValue
                                }
                            }
                        ))
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 50)
                        Text("日")
                    }
                    
                    // 通知時間
                    DatePicker("通知時間", selection: $notificationTime, displayedComponents: [.hourAndMinute])
                }
            }
            .navigationTitle("タスクを編集")
            .navigationBarItems(
                leading: Button("戻る") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("保存") {
                    saveTaskChanges()
                    dismiss()
                }
            )
        }
        .onAppear {
            // onAppearで初期化
            lastCompletedDate = task.lastCompletedDate ?? Date()
            notificationTime = task.notificationTime ?? Date()
            alertDays = task.alertDays ?? 0 // ✅ UserDefaults のデータが null の場合も防ぐ
        }
    }
    
    private func saveTaskChanges() {
        // ✅ `alertDays` の値を `task.alertDays` に保存
        task.lastCompletedDate = lastCompletedDate
        task.notificationTime = notificationTime
        task.alertDays = alertDays
        
        NotificationManager.shared.cancelNotification(task: task)
        NotificationManager.shared.scheduleHabitTaskNotification(task: task)
        saveTasks()
    }

    private func saveTasks() {
        // UserDefaults への保存
        if let tasksData = UserDefaults.standard.data(forKey: "tasks"),
           var tasks = try? JSONDecoder().decode([Task].self, from: tasksData),
           let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            UserDefaults.standard.set(try? JSONEncoder().encode(tasks), forKey: "tasks")
        }
    }
}
