import SwiftUI

struct AddTaskView: View {
    @Binding var tasks: [Task]
    @Environment(\.presentationMode) var presentationMode

    @State private var title: String = ""
    @State private var taskType: TaskType = .habit
    @State private var dueDate: Date = Date()
    @State private var lastCompletedDate: Date = Date() // 最終実行日
    @State private var alertDays: String = "" // 警告日数 (String)
    @State private var notificationTime: Date = Date() // 🔔 通知時間
    @State private var snoozeText: String = ""
    @State private var selectedSnoozeMinutes: Int = 5 // デフォルト5分

    // 5〜60分までの5分刻みの配列
    let snoozeOptions = Array(stride(from: 5, through: 60, by: 5))
    
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
                    
                    HStack {
                        Text("警告日数")
                        Spacer()
                        TextField("0", text: $alertDays)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 50)
                            .onChange(of: alertDays) { oldValue, newValue in
                                alertDays = String(newValue.prefix(3)).filter { "0123456789".contains($0) }
                            }
                        Text("日")
                    }

                    // 🔔 通知時間を選択
                    DatePicker("通知時間", selection: $notificationTime, displayedComponents: [.hourAndMinute])
                }

                if taskType == .reminder {
                    DatePicker("通知時間", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    
                    Picker("スヌーズ", selection: $selectedSnoozeMinutes) {
                        ForEach(snoozeOptions, id: \.self) { minutes in
                            Text("\(minutes) 分").tag(minutes)
                        }
                    }
                }
            }
            .navigationTitle("タスクを追加")
            .navigationBarItems(
                leading: Button("キャンセル") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("保存") {
                    let alertDaysInt = Int(alertDays) ?? 0

                    let newTask = Task(
                        title: title,
                        taskType: taskType,
                        lastCompletedDate: taskType == .habit ? lastCompletedDate : nil,
                        dueDate: taskType == .reminder ? dueDate : nil,
                        alertDays: taskType == .habit ? alertDaysInt : nil,
                        notificationTime: taskType == .habit ? notificationTime : nil,
                        snoozeMinutes: taskType == .reminder ? selectedSnoozeMinutes : nil,
                        isCompleted: false
                    )

                    tasks.append(newTask)
                    saveTasks()

                    // ✅ タスク作成後に通知をスケジュール
                    if newTask.taskType == .habit {
                        NotificationManager.shared.scheduleHabitTaskNotification(task: newTask)
                    }
                    if newTask.taskType == .reminder {
                        NotificationManager.shared.scheduleReminderTaskNotification(task: newTask)
                    }

                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }

    private func saveTasks() {
        UserDefaults.standard.set(try? JSONEncoder().encode(tasks), forKey: "tasks")
    }
}
