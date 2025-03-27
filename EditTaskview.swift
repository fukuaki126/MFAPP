import SwiftUI

struct EditTaskView: View {
    @Binding var task: Task // 変更: 配列ではなく単一のタスクをバインド
    @Environment(\.dismiss) var dismiss

    @State private var title: String
    @State private var dueDate: Date
    @State private var isCompleted: Bool

    init(task: Binding<Task>) {
        self._task = task
        _title = State(initialValue: task.wrappedValue.title)
        _dueDate = State(initialValue: task.wrappedValue.dueDate ?? Date())
        _isCompleted = State(initialValue: task.wrappedValue.isCompleted)
    }

    var body: some View {
        Form {
            Section(header: Text("タスク詳細")) {
                TextField("タスク名", text: $title)
                DatePicker("通知時間", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                Toggle("完了", isOn: $isCompleted)
            }
        }
        .navigationTitle("タスクを編集")
        .navigationBarItems(
            trailing: Button("保存") {
                task.title = title
                task.dueDate = dueDate
                task.isCompleted = isCompleted
                saveTasks()
                dismiss()
            }
        )
    }

    private func saveTasks() {
        UserDefaults.standard.set(try? JSONEncoder().encode([task]), forKey: "tasks")
    }
}
