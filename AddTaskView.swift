import SwiftUI

struct AddTaskView: View {
    @Binding var tasks: [Task]
    @Environment(\.presentationMode) var presentationMode

    @State private var title: String = ""
    @State private var taskType: TaskType = .habit
    @State private var dueDate: Date = Date()
    @State private var lastCompletedDate: Date = Date() // 追加

    var body: some View {
        NavigationView {
            Form {
                TextField("タスク名", text: $title)

                Picker("タスクの種類", selection: $taskType) {
                    ForEach(TaskType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                
                if taskType == .habit {
                    DatePicker("最終実行日", selection: $lastCompletedDate, displayedComponents: [.date])
                }

                if taskType == .reminder {
                    DatePicker("期限", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                }
            }
            .navigationTitle("タスクを追加")
            .navigationBarItems(leading: Button("キャンセル") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("保存") {
                let newTask = Task(
                    title: title,
                    taskType: taskType,
                    lastCompletedDate: taskType == .habit ? lastCompletedDate : nil,
                    dueDate: taskType == .reminder ? dueDate : nil,
                    isCompleted: false
                )
                tasks.append(newTask)
                saveTasks()
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    private func saveTasks() {
        UserDefaults.standard.set(try? JSONEncoder().encode(tasks), forKey: "tasks")
    }
}
