import SwiftUI

struct EditHabitTaskView: View {
    @Binding var task: Task
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode

    // 一時的な @State 変数を使用
    @State private var lastCompletedDate: Date
    @State private var dueDate: Date
    @State private var alertDays: Int

    init(task: Binding<Task>) {
        self._task = task
        // task の値を初期化する
        _lastCompletedDate = State(initialValue: task.wrappedValue.lastCompletedDate ?? Date())
        _dueDate = State(initialValue: task.wrappedValue.dueDate ?? Date())
        _alertDays = State(initialValue: task.wrappedValue.alertDays ?? 0) // ✅ nilを防ぐ
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
                            get: { String(alertDays) }, // ✅ Int を String に変換
                            set: { newValue in
                                if let intValue = Int(newValue) { // ✅ 数値変換が成功した場合のみ更新
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
                    DatePicker("通知時間", selection: $dueDate, displayedComponents: [.hourAndMinute])
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
            dueDate = task.dueDate ?? Date()
            alertDays = task.alertDays ?? 0 // ✅ UserDefaults のデータが null の場合も防ぐ
        }
    }
    
    private func saveTaskChanges() {
        // ✅ `alertDays` の値を `task.alertDays` に保存
        task.lastCompletedDate = lastCompletedDate
        task.dueDate = dueDate
        task.alertDays = alertDays // ✅ ここを追加
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
