import SwiftUI

struct EditTaskView: View {
    @Binding var task: Task
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode // 画面を閉じるために必要

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("タスク詳細")) {
                    TextField("タスク名", text: $task.title)
                    DatePicker("通知時間", selection: Binding(
                        get: { task.dueDate ?? Date() },
                        set: { task.dueDate = $0 }
                    ), displayedComponents: [.date, .hourAndMinute])
                    Toggle("完了", isOn: $task.isCompleted)
                }
            }
            .navigationTitle("タスクを編集")
            .navigationBarItems(
                leading: Button("戻る") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("保存") {
                    saveTasks()
                    dismiss()
                }
            )
        }
    }

    private func saveTasks() {
        // `task` は `tasks` の中の1つをバインドしているため、tasks 全体を取得する
        if let tasksData = UserDefaults.standard.data(forKey: "tasks"),
           var tasks = try? JSONDecoder().decode([Task].self, from: tasksData),
           let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            UserDefaults.standard.set(try? JSONEncoder().encode(tasks), forKey: "tasks")
        }
    }
}
