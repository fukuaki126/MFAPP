import SwiftUI

struct EditHabitTaskView: View {
    @Binding var tasks: [Task]
    @Environment(\.presentationMode) var presentationMode
    
    // Task to be edited
    var taskToEdit: Task
    
    // State variables to hold task details
    @State private var title: String
    @State private var lastCompletedDate: Date
    @State private var alertDays: String
    @State private var notificationTime: Date
    
    // Initialize with the task to be edited
    init(tasks: Binding<[Task]>, taskToEdit: Task) {
        self._tasks = tasks
        self.taskToEdit = taskToEdit
        
        // Initialize state variables with task's current values
        _title = State(initialValue: taskToEdit.title)
        _lastCompletedDate = State(initialValue: taskToEdit.lastCompletedDate ?? Date())
        _alertDays = State(initialValue: String(taskToEdit.alertDays ?? 0))
        _notificationTime = State(initialValue: taskToEdit.notificationTime ?? Date())
    }
    
    var body: some View {
        Form {
            Section(header: Text("タスク詳細")) {
                TextField("タスク名", text: $title)
                
                DatePicker("最終実行日",
                           selection: $lastCompletedDate,
                           displayedComponents: [.date])
                
                HStack {
                    Text("警告日数")
                    Spacer()
                    TextField("0", text: $alertDays)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 50)
                        .onChange(of: alertDays) { newValue in
                            // 数値以外を削除し、3桁に制限
                            alertDays = String(newValue.prefix(3)).filter { "0123456789".contains($0) }
                        }
                    Text("日")
                }
                
                DatePicker("通知時間",
                           selection: $notificationTime,
                           displayedComponents: [.hourAndMinute])
            }
        }
        .navigationTitle("タスクを編集")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("保存") {
                    saveTask()
                }
                .font(.body) // ✅ 高さを戻るボタンと統一
            }
        }
    }
    
    private func saveTask() {
        if let index = tasks.firstIndex(where: { $0.id == taskToEdit.id }) {
            tasks[index].title = title
            tasks[index].lastCompletedDate = lastCompletedDate
            tasks[index].alertDays = Int(alertDays) ?? 0
            tasks[index].notificationTime = notificationTime
            
            // Save tasks and reschedule notifications
            saveTasks()
            NotificationManager.shared.scheduleHabitTaskNotification(task: tasks[index])
            
            // Dismiss the view
            presentationMode.wrappedValue.dismiss()
        }
    }

    private func saveTasks() {
        UserDefaults.standard.set(try? JSONEncoder().encode(tasks), forKey: "tasks")
    }
}
