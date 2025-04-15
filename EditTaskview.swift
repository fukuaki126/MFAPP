import SwiftUI

struct EditTaskView: View {
    @Binding var task: Task
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    // 5〜60分までの5分刻みの配列
    let snoozeOptions = Array(stride(from: 5, through: 60, by: 5))

    // 一時的な状態変数（文字列で入力 → 数値へ変換）
    @State private var snoozeText: String = ""
    @State private var selectedSnoozeMinutes: Int = 5 // デフォルト5分
    // 一時的な @State 変数を使用
    @State private var dueDate: Date
    @State private var snoozeMinutes: Int
    init(task: Binding<Task>) {
        self._task = task
        // task の値を初期化する
        _dueDate = State(initialValue: task.wrappedValue.dueDate ?? Date())
        _snoozeMinutes = State(initialValue: task.wrappedValue.snoozeMinutes ?? Int())
    }
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("タスク詳細")) {
                    TextField("タスク名", text: $task.title)

                    // ✅ シンプルな通知時間 DatePicker
                    DatePicker("通知時間", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])

                    Toggle("完了", isOn: $task.isCompleted)

                    Picker("スヌーズ", selection: $task.snoozeMinutes) {
                        ForEach(snoozeOptions, id: \.self) { minutes in
                            Text("\(minutes) 分").tag(minutes)
                        }
                    }
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
            // 編集画面表示時に現在のスヌーズ値を表示
            snoozeText = String(task.snoozeMinutes ?? 5) // デフォルト5分
        }
    }
    private func saveTaskChanges() {
        task.dueDate = dueDate
        task.snoozeMinutes = snoozeMinutes

        NotificationManager.shared.cancelNotification(task: task)
        NotificationManager.shared.scheduleReminderTaskNotification(task: task)
        
        saveTasks()
    }

    private func saveTasks() {
        if let tasksData = UserDefaults.standard.data(forKey: "tasks"),
           var tasks = try? JSONDecoder().decode([Task].self, from: tasksData),
           let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            UserDefaults.standard.set(try? JSONEncoder().encode(tasks), forKey: "tasks")
        }
    }
}
